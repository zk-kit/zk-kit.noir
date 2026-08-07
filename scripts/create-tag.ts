import { execSync } from 'child_process'
import { readdirSync, statSync } from 'fs'
import { join } from 'path'

interface Options {
  commit: string
  force: boolean
}

function showHelp(): void {
  console.log(`
Usage: bun run version:tag <package> <version> [commit] [options]

Create a git tag for a package release.

Arguments:
  package               Package name (must exist in packages/)
  version               Version number (semver format: X.Y.Z)
  commit                Commit SHA or ref to tag (default: HEAD)

Options:
  --commit, -c <ref>    Commit SHA or ref to tag (alternative to positional)
  --force, -f           Force overwrite existing tag
  --help, -h            Show this help message

Examples:
  bun run version:tag merkle-trees 1.0.0
  bun run version:tag merkle-trees 1.0.0 abc123
  bun run version:tag ecdh 2.0.0 abc123
  bun run version:tag merkle-trees 1.0.0 --commit abc123
  bun run version:tag merkle-trees 1.0.0 --force
`)
}

function getValidPackages(): string[] {
  const packagesDir = join(process.cwd(), 'packages')
  try {
    return readdirSync(packagesDir).filter((name) => {
      const fullPath = join(packagesDir, name)
      return statSync(fullPath).isDirectory() && !name.startsWith('.')
    })
  } catch {
    console.error('❌ Could not read packages directory')
    process.exit(1)
  }
}

function isValidVersion(version: string): boolean {
  // Semver pattern: X.Y.Z with optional prerelease and metadata
  const semverPattern = /^\d+\.\d+\.\d+(-[a-zA-Z0-9.-]+)?(\+[a-zA-Z0-9.-]+)?$/
  return semverPattern.test(version)
}

function isValidCommitRef(ref: string): boolean {
  try {
    execSync(`git rev-parse --verify ${ref}`, { stdio: 'pipe' })
    return true
  } catch {
    return false
  }
}

function tagExists(tagName: string): boolean {
  try {
    execSync(`git rev-parse --verify refs/tags/${tagName}`, { stdio: 'pipe' })
    return true
  } catch {
    return false
  }
}

function parseArgs(args: string[]): { packageName: string; version: string; options: Options } | null {
  const options: Options = {
    commit: 'HEAD',
    force: false,
  }

  let packageName = ''
  let version = ''
  let commitFlagUsed = false
  const positionalArgs: string[] = []

  for (let i = 0; i < args.length; i++) {
    const arg = args[i]

    if (arg === '--help' || arg === '-h') {
      showHelp()
      process.exit(0)
    } else if (arg === '--force' || arg === '-f')
      options.force = true
    else if (arg === '--commit' || arg === '-c') {
      const nextArg = args[++i]
      if (!nextArg) {
        console.error('❌ --commit requires a value')
        process.exit(1)
      }
      options.commit = nextArg
      commitFlagUsed = true
    } else if (arg.startsWith('-')) {
      console.error(`❌ Unknown option: ${arg}`)
      showHelp()
      process.exit(1)
    } else {
      positionalArgs.push(arg)
    }
  }

  if (positionalArgs.length < 2)
    return null

  packageName = positionalArgs[0]
  version = positionalArgs[1]

  // Use 3rd positional argument as commit ref if --commit flag wasn't used
  if (positionalArgs.length >= 3 && !commitFlagUsed)
    options.commit = positionalArgs[2]

  return { packageName, version, options }
}

// Main execution
const args = process.argv.slice(2)

// Handle --help with no args
if (args.length === 0 || args.includes('--help') || args.includes('-h')) {
  showHelp()
  process.exit(args.length === 0 ? 1 : 0)
}

const parsed = parseArgs(args)

if (!parsed) {
  console.error('❌ Please provide a package name and version')
  showHelp()
  process.exit(1)
}

const { packageName, version, options } = parsed

// Validate package name
const validPackages = getValidPackages()
if (!validPackages.includes(packageName)) {
  console.error(`❌ Invalid package: "${packageName}"`)
  console.error(`   Valid packages: ${validPackages.join(', ')}`)
  process.exit(1)
}

// Validate version format
if (!isValidVersion(version)) {
  console.error(`❌ Invalid version format: "${version}"`)
  console.error('   Expected semver format: X.Y.Z (e.g., 1.0.0, 2.1.3-beta.1)')
  process.exit(1)
}

// Validate commit reference
if (!isValidCommitRef(options.commit)) {
  console.error(`❌ Invalid commit reference: "${options.commit}"`)
  process.exit(1)
}

const tagName = `${packageName}-v${version}`

// Check if tag already exists
if (tagExists(tagName)) {
  if (!options.force) {
    console.error(`❌ Tag "${tagName}" already exists`)
    console.error('   Use --force to overwrite the existing tag')
    process.exit(1)
  }
  // Delete existing tag if force is enabled
  try {
    execSync(`git tag -d ${tagName}`, { stdio: 'pipe' })
  } catch {
    console.error(`❌ Failed to delete existing tag "${tagName}"`)
    process.exit(1)
  }
}

// Create the tag
try {
  execSync(`git tag ${tagName} ${options.commit}`, { stdio: 'inherit' })
  const commitDisplay = options.commit === 'HEAD' ? 'HEAD' : options.commit.substring(0, 7)
  console.log(`✅ Created git tag: ${tagName} (at ${commitDisplay})`)
} catch (err) {
  console.error(`❌ Failed to create git tag "${tagName}"`, err)
  process.exit(1)
}
