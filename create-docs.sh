# Create the documentation for Forms
jazzy \
--author "Josh Campion @ The Distance" \
--author_url "https://thedistance.co.uk" \
--github_url "https://github.com/thedistance/TheDistanceForms" \
--xcodebuild-arguments -scheme,"TheDistanceForms" \
--module "TheDistanceForms" \
--readme "ReadMe.md" \
--output "docs/TheDistanceForms"

# Create the documentation for Photos & Videos Forms
jazzy \
--author "Josh Campion @ The Distance" \
--author_url "https://thedistance.co.uk" \
--github_url "https://github.com/thedistance/TheDistanceForms" \
--xcodebuild-arguments -scheme,"TheDistanceFormsPhotosVideos" \
--module "TheDistanceFormsPhotosVideos" \
--output "docs/TheDistanceFormsPhotosVideos"

# Create the documentation for Themed
jazzy \
--author "Josh Campion @ The Distance" \
--author_url "https://thedistance.co.uk" \
--github_url "https://github.com/thedistance/TheDistanceForms" \
--xcodebuild-arguments -scheme,"TheDistanceFormsThemed" \
--module "TheDistanceFormsThemed" \
--output "docs/TheDistanceFormsThemed"
