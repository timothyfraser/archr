# tutorial_github.R

# Wondering why you can't push to Github?
# This might help!
# You may have found another solution already - if so, just roll with that.

# Make a personal access token (PAT)
# https://github.com/settings/tokens

# Install credentials package
install.packages("credentials")

# Set github personal-access-token (PAT)
credentials::set_github_pat()

