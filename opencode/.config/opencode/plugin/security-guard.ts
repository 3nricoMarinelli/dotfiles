/**
 * ╔═══════════════════════════════════════════════════════════════════════════╗
 * ║                                                                           ║
 * * ║  🛡️ OPENCODE SECURITY GUARD PLUGIN 🛡️                                 ║
 * ║                                                                           ║
 * ║  Protects sensitive files/directories from read/write/execute operations ║
 * ║                                                                           ║
 * ╚═══════════════════════════════════════════════════════════════════════════╝
 *
 * This plugin provides:
 * - Sensitive file/directory pattern matching
 * - Security guard tools for file access control
 * - Permission integration for bash commands accessing sensitive paths
 */
import type { Plugin, PluginInput, Hooks } from "@opencode-ai/plugin";
import { tool } from "@opencode-ai/plugin";
import { realpathSync, existsSync } from "node:fs";
import { join, normalize, resolve, sep } from "node:path";
import { homedir } from "node:os";

export interface SensitivePattern {
  pattern: string;
  description: string;
  severity: "critical" | "high" | "medium";
}

export interface GuardConfig {
  sensitivePatterns: SensitivePattern[];
  additionalAllowedDirs: string[];
  additionalBlockedDirs: string[];
}

const DEFAULT_SENSITIVE_PATTERNS: SensitivePattern[] = [
  { pattern: "**/.env*", description: "Environment variables", severity: "critical" },
  { pattern: "**/.env.*", description: "Environment variables", severity: "critical" },
  { pattern: "**/credentials.json", description: "Google/service credentials", severity: "critical" },
  { pattern: "**/*.pem", description: "SSH/TLS private keys", severity: "critical" },
  { pattern: "**/*.key", description: "Private keys", severity: "critical" },
  { pattern: "**/id_rsa*", description: "SSH keys", severity: "critical" },
  { pattern: "**/id_ed25519*", description: "SSH keys", severity: "critical" },
  { pattern: "**/.ssh/*", description: "SSH configuration", severity: "critical" },
  { pattern: "**/secrets.yaml", description: "Kubernetes secrets", severity: "critical" },
  { pattern: "**/secrets.yml", description: "Kubernetes secrets", severity: "critical" },
  { pattern: "**/.aws/credentials", description: "AWS credentials", severity: "critical" },
  { pattern: "**/.aws/config", description: "AWS config", severity: "high" },
  { pattern: "**/config/secrets.*", description: "App secrets config", severity: "critical" },
  { pattern: "**/private/*", description: "Private directories", severity: "high" },
  { pattern: "**/.npmrc", description: "NPM config (may contain tokens)", severity: "high" },
  { pattern: "**/.pypirc", description: "PyPI config (may contain tokens)", severity: "high" },
  { pattern: "**/serviceAccountKey.json", description: "Firebase service account", severity: "critical" },
  { pattern: "**/github_token", description: "GitHub tokens", severity: "critical" },
  { pattern: "**/.netrc", description: "Network credentials", severity: "critical" },
  { pattern: "**/wp-config.php", description: "WordPress config", severity: "high" },
  { pattern: "**/database.yml", description: "Rails database config", severity: "high" },
  { pattern: "**/settings_local.py", description: "Django local settings", severity: "high" },
  { pattern: "**/.htpasswd", description: "HTTP authentication", severity: "high" },
  { pattern: "**/shadow", description: "Linux password hashes", severity: "critical" },
  { pattern: "**/passwd", description: "Linux user database (read-only risk)", severity: "medium" },
  { pattern: "**/.gnupg/*", description: "GPG keys", severity: "critical" },
  { pattern: "**/bitcoin_wallet.dat", description: "Cryptocurrency wallets", severity: "critical" },
  { pattern: "**/wallet.dat", description: "Cryptocurrency wallets", severity: "critical" },
  { pattern: "**/.kube/config", description: "Kubernetes config", severity: "high" },
  { pattern: "**/.docker/config.json", description: "Docker credentials", severity: "high" },
];

const DEFAULT_BLOCKED_DIRS = [
  "/etc",
  "/private/etc",
  "/System",
  "/usr/bin",
  "/usr/sbin",
  "/bin",
  "/sbin",
  "/boot",
  "/proc",
  "/sys",
  "/dev",
];

const DEFAULT_ALLOWED_EXTERNAL_DIRS = [
  join(homedir(), "workspace"),
  join(homedir(), "projects"),
  join(homedir(), "dev"),
];

function normalizePath(path: string): string {
  try {
    return normalize(resolve(path));
  } catch {
    return normalize(path);
  }
}

function pathMatchesPattern(filePath: string, pattern: string): boolean {
  const normalizedPath = normalizePath(filePath);
  const normalizedPattern = pattern.replace(/\*\*/g, "**").replace(/\*/g, "[^/]*");
  
  const regexPattern = normalizedPattern
    .replace(/\.\*\*/g, "(?:.*)")
    .replace(/\*\./g, "[^/]*\\.")
    .replace(/\./g, "\\.")
    .replace(/\?/g, ".");
  
  try {
    const regex = new RegExp(`^${regexPattern}$`, "i");
    return regex.test(normalizedPath) || 
           regex.test(normalizedPath.split(sep).join("/")) ||
           normalizedPath.includes(pattern.replace(/\*\*/g, "").replace(/\*/g, ""));
  } catch {
    return false;
  }
}

function isInBlockedDir(filePath: string, blockedDirs: string[]): boolean {
  const normalizedPath = normalizePath(filePath);
  
  for (const dir of blockedDirs) {
    const normalizedDir = normalizePath(dir);
    if (normalizedPath.startsWith(normalizedDir + sep) || normalizedPath === normalizedDir) {
      return true;
    }
  }
  return false;
}

function isSensitivePath(
  filePath: string,
  patterns: SensitivePattern[],
  blockedDirs: string[],
): { isSensitive: boolean; match?: SensitivePattern; reason?: string } {
  const normalizedPath = normalizePath(filePath);
  
  if (isInBlockedDir(normalizedPath, blockedDirs)) {
    return {
      isSensitive: true,
      reason: `Path is in blocked system directory`,
    };
  }
  
  for (const pattern of patterns) {
    if (pathMatchesPattern(normalizedPath, pattern.pattern) || 
        pathMatchesPattern(normalizedPath.split(sep).join("/"), pattern.pattern)) {
      return {
        isSensitive: true,
        match: pattern,
        reason: `Matches pattern: ${pattern.pattern} (${pattern.description})`,
      };
    }
  }
  
  return { isSensitive: false };
}

const security_guard_check = tool({
  description: `Check if a file or directory path is sensitive/protected.

This tool validates paths against security patterns and returns:
- isSensitive: boolean indicating if the path is protected
- match: the matching pattern if found
- severity: critical/high/medium based on pattern
- reason: human-readable explanation

Use this BEFORE attempting to read/write sensitive files.`,
  args: {
    path: tool.schema.string().describe("File or directory path to check"),
    checkContent: tool.schema.boolean().optional().describe("Also check file content for secrets"),
  },
  execute: async (args): Promise<string> => {
    const { path, checkContent = false } = args;
    
    const result = isSensitivePath(path, DEFAULT_SENSITIVE_PATTERNS, DEFAULT_BLOCKED_DIRS);
    
    if (result.isSensitive) {
      const response = {
        allowed: false,
        path: path,
        isSensitive: true,
        severity: result.match?.severity || "high",
        reason: result.reason,
        pattern: result.match?.pattern,
        description: result.match?.description,
      };
      return JSON.stringify(response, null, 2);
    }
    
    if (checkContent && existsSync(path)) {
      const { readFileSync } = require("node:fs");
      try {
        const content = readFileSync(path, "utf-8");
        const contentPatterns = [
          { regex: /-----BEGIN (RSA |EC |DSA |OPENSSH )?PRIVATE KEY-----/, type: "private key" },
          { regex: /AKIA[0-9A-Z]{16}/, type: "AWS access key" },
          { regex: /gh[pousr]_[a-zA-Z0-9]{36,}/, type: "GitHub token" },
          { regex: /xox[baprs]-[0-9a-zA-Z-]{10,}/, type: "Slack token" },
          { regex: /sk-[a-zA-Z0-9]{32,}/, type: "OpenAI API key" },
        ];
        
        for (const cp of contentPatterns) {
          if (cp.regex.test(content)) {
            return JSON.stringify({
              allowed: false,
              path: path,
              isSensitive: true,
              severity: "critical",
              reason: `File content contains ${cp.type}`,
            }, null, 2);
          }
        }
      } catch {
      }
    }
    
    return JSON.stringify({
      allowed: true,
      path: path,
      isSensitive: false,
      reason: "Path is not protected",
    }, null, 2);
  },
});

const security_guard_list_patterns = tool({
  description: `List all sensitive file patterns protected by the security guard.

Returns patterns organized by severity (critical, high, medium).`,
  args: {},
  execute: async (): Promise<string> => {
    const bySeverity: Record<string, SensitivePattern[]> = {
      critical: [],
      high: [],
      medium: [],
    };
    
    for (const pattern of DEFAULT_SENSITIVE_PATTERNS) {
      bySeverity[pattern.severity].push(pattern);
    }
    
    return JSON.stringify({
      totalPatterns: DEFAULT_SENSITIVE_PATTERNS.length,
      blockedDirs: DEFAULT_BLOCKED_DIRS,
      patterns: bySeverity,
    }, null, 2);
  },
});

const security_guard_check_bash = tool({
  description: `Check if a bash command attempts to access sensitive paths.

Analyzes the command for:
- File read/write operations on protected paths
- Commands that could expose sensitive data
- Pipe/redirect operations to sensitive files`,
  args: {
    command: tool.schema.string().describe("Bash command to analyze"),
  },
  execute: async (args): Promise<string> => {
    const { command } = args;
    const sensitiveKeywords = [
      { keyword: "cat.*\\.env", severity: "critical", reason: "Reading .env file" },
      { keyword: "cat.*credentials", severity: "critical", reason: "Reading credentials" },
      { keyword: "cat.*\\.pem", severity: "critical", reason: "Reading private key" },
      { keyword: "cat.*\\.key", severity: "critical", reason: "Reading private key" },
      { keyword: "cat.*id_rsa", severity: "critical", reason: "Reading SSH key" },
      { keyword: ".*\\.aws/credentials", severity: "critical", reason: "Reading AWS credentials" },
      { keyword: "grep.*password", severity: "high", reason: "Searching for passwords" },
      { keyword: "chmod\\s+777", severity: "high", reason: "Overly permissive chmod" },
      { keyword: ">\s*/etc/", severity: "critical", reason: "Writing to system directory" },
      { keyword: ">\s*~/\\.", severity: "high", reason: "Writing to home directory file" },
      { keyword: "tar\\s+.*\\.gz\\s+.*\\.env", severity: "critical", reason: "Archiving .env file" },
      { keyword: "scp.*\\.pem", severity: "critical", reason: "Copying private key" },
      { keyword: "ssh.*-i.*\\.pem", severity: "critical", reason: "Using private key for SSH" },
    ];
    
    const warnings: { match: string; severity: string; reason: string }[] = [];
    
    for (const kw of sensitiveKeywords) {
      const regex = new RegExp(kw.keyword, "i");
      if (regex.test(command)) {
        warnings.push({
          match: kw.keyword,
          severity: kw.severity,
          reason: kw.reason,
        });
      }
    }
    
    if (warnings.length > 0) {
      return JSON.stringify({
        allowed: false,
        command: command,
        blocked: true,
        warnings: warnings,
        reason: "Command attempts to access sensitive paths",
      }, null, 2);
    }
    
    return JSON.stringify({
      allowed: true,
      command: command,
      blocked: false,
      reason: "Command appears safe",
    }, null, 2);
  },
});

const opencode = {
  name: "security-guard",
  version: "1.0.0",
  tools: [
    security_guard_check,
    security_guard_list_patterns,
    security_guard_check_bash,
  ],
  hooks: {
    "before-read": async (input: { filePath: string }): Promise<{ allowed: boolean; reason?: string }> => {
      const result = isSensitivePath(input.filePath, DEFAULT_SENSITIVE_PATTERNS, DEFAULT_BLOCKED_DIRS);
      if (result.isSensitive) {
        return {
          allowed: false,
          reason: `Read blocked: ${result.reason}`,
        };
      }
      return { allowed: true };
    },
    "before-write": async (input: { filePath: string }): Promise<{ allowed: boolean; reason?: string }> => {
      const result = isSensitivePath(input.filePath, DEFAULT_SENSITIVE_PATTERNS, DEFAULT_BLOCKED_DIRS);
      if (result.isSensitive) {
        return {
          allowed: false,
          reason: `Write blocked: ${result.reason}`,
        };
      }
      return { allowed: true };
    },
    "before-bash": async (input: { command: string }): Promise<{ allowed: boolean; reason?: string }> => {
      const dangerousPatterns = [
        { pattern: /rm\s+-rf\s+\/(?:\s|$)/, reason: "Attempting to delete root filesystem" },
        { pattern: /rm\s+-rf\s+\/etc/, reason: "Attempting to delete system directory" },
        { pattern: />\s*\/etc\/passwd/, reason: "Attempting to modify system users" },
        { pattern: />\s*\/etc\/shadow/, reason: "Attempting to modify password hashes" },
        { pattern: /dd\s+if=.*of=\/dev\//, reason: "Direct device write" },
        { pattern: /mkfs\./, reason: "Filesystem format attempt" },
      ];
      
      for (const dp of dangerousPatterns) {
        if (dp.pattern.test(input.command)) {
          return {
            allowed: false,
            reason: `Blocked: ${dp.reason}`,
          };
        }
      }
      return { allowed: true };
    },
  } as Hooks,
};

export default opencode;
