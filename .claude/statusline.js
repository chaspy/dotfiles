#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const os = require('os');

// Claude Code transcript directory
const TRANSCRIPT_DIR = path.join(os.homedir(), '.claude', 'transcripts');

// Model context limits (tokens)
const MODEL_LIMITS = {
  'claude-sonnet-4-20250514': 200000,
  'claude-3.5-sonnet': 200000,
  'claude-3-opus': 200000,
  'claude-3-sonnet': 200000,
  'claude-3-haiku': 200000,
  // Add other models as needed
};

function formatTokens(tokens) {
  if (tokens >= 1000000) {
    return `${(tokens / 1000000).toFixed(1)}M`;
  } else if (tokens >= 1000) {
    return `${(tokens / 1000).toFixed(1)}K`;
  }
  return tokens.toString();
}

function getColorCode(percentage) {
  if (percentage >= 80) return '\x1b[31m'; // Red
  if (percentage >= 60) return '\x1b[33m'; // Yellow
  return '\x1b[32m'; // Green
}

function resetColor() {
  return '\x1b[0m';
}

async function getCurrentTokenUsage() {
  try {
    // Check if transcript directory exists
    if (!fs.existsSync(TRANSCRIPT_DIR)) {
      console.error(`Debug: Transcript directory not found: ${TRANSCRIPT_DIR}`);
      return { tokens: 0, model: 'unknown', percentage: 0 };
    }

    // Get the most recent transcript file
    const files = fs.readdirSync(TRANSCRIPT_DIR)
      .filter(file => file.endsWith('.json'))
      .map(file => ({
        name: file,
        time: fs.statSync(path.join(TRANSCRIPT_DIR, file)).mtime.getTime()
      }))
      .sort((a, b) => b.time - a.time);

    if (files.length === 0) {
      console.error(`Debug: No transcript files found in ${TRANSCRIPT_DIR}`);
      return { tokens: 0, model: 'unknown', percentage: 0 };
    }

    const latestFile = path.join(TRANSCRIPT_DIR, files[0].name);
    console.error(`Debug: Reading file: ${latestFile}`);
    
    const content = fs.readFileSync(latestFile, 'utf8');
    const transcript = JSON.parse(content);

    let totalTokens = 0;
    let model = 'unknown';

    // Parse messages to count tokens
    if (transcript.messages && Array.isArray(transcript.messages)) {
      console.error(`Debug: Found ${transcript.messages.length} messages`);
      for (const message of transcript.messages) {
        if (message.usage) {
          if (message.usage.input_tokens) {
            totalTokens += message.usage.input_tokens;
          }
          if (message.usage.output_tokens) {
            totalTokens += message.usage.output_tokens;
          }
        }
        if (message.model && model === 'unknown') {
          model = message.model;
        }
      }
    } else {
      console.error(`Debug: No messages array found`);
      // Try alternative structure
      if (transcript.usage) {
        if (transcript.usage.input_tokens) totalTokens += transcript.usage.input_tokens;
        if (transcript.usage.output_tokens) totalTokens += transcript.usage.output_tokens;
      }
      if (transcript.model) {
        model = transcript.model;
      }
    }

    console.error(`Debug: Total tokens: ${totalTokens}, Model: ${model}`);

    // Calculate percentage based on model limit
    const limit = MODEL_LIMITS[model] || 200000;
    const percentage = Math.min((totalTokens / limit) * 100, 100);

    return { tokens: totalTokens, model, percentage };
  } catch (error) {
    console.error(`Debug: Error: ${error.message}`);
    return { tokens: 0, model: 'unknown', percentage: 0 };
  }
}

async function getGitBranch() {
  try {
    const { execSync } = require('child_process');
    const branch = execSync('git rev-parse --abbrev-ref HEAD 2>/dev/null', { 
      encoding: 'utf8',
      cwd: process.cwd()
    }).trim();
    return branch;
  } catch {
    return '-';
  }
}

async function main() {
  const { tokens, model, percentage } = await getCurrentTokenUsage();
  const branch = await getGitBranch();
  const currentDir = path.basename(process.cwd());
  
  const colorCode = getColorCode(percentage);
  const resetCode = resetColor();
  
  const formattedTokens = formatTokens(tokens);
  const formattedPercentage = `${colorCode}${percentage.toFixed(1)}%${resetCode}`;
  
  const statusLine = `📁 ${currentDir} 🌿 ${branch} 🤖 ${model.split('-').pop() || model} 🔢 ${formattedTokens} ${formattedPercentage}`;
  
  console.log(statusLine);
}

main().catch(console.error);