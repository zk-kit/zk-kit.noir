import { execSync } from 'child_process'
import { readFileSync, writeFileSync } from 'fs'

const packageName = process.argv[2]
const version = process.argv[3]

if (!packageName || !version) {
  console.error('❌ Please provide a package name and version')
  process.exit(1)
}

const tag = `${packageName}-v${version}`
const readmePath = `packages/${packageName}/README.md`

try {
  const readme = readFileSync(readmePath, 'utf8')
  const tagPattern = `tag = "${packageName}-v[0-9]+\\.[0-9]+\\.[0-9]+"`

  if (!new RegExp(tagPattern).test(readme)) {
    console.error(`❌ No install snippet with a "${packageName}-v..." tag found in ${readmePath}`)
    process.exit(1)
  }

  // Bump every `tag = "<package>-vX.Y.Z"` in the install snippet.
  const updated = readme.replace(new RegExp(tagPattern, 'g'), `tag = "${tag}"`)

  // Already at this version (e.g. a first release) — nothing to commit.
  if (updated !== readme) {
    writeFileSync(readmePath, updated)

    execSync(`git add ${readmePath}`, { stdio: 'inherit' })
    // NO_HOOK=1 skips the interactive `czg` prepare-commit-msg hook.
    execSync(`NO_HOOK=1 git commit -m "docs(${packageName}): update install version to ${version}"`)
  }

  execSync(`git tag ${tag}`, { stdio: 'inherit' })

  console.log(`✅ Updated ${readmePath} and created git tag: ${tag}`)
  console.log(`👉 Now run: git push && git push origin ${tag}`)
} catch (err) {
  console.error('❌ Failed to create git tag', err)
  process.exit(1)
}
