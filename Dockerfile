#
# STN Dockerfile
#
# Utilizing: https://github.com/yoshz/ghost
#

# Pull base image.

#FROM dockerfile/ghost  ## Used to be...but I like configuration through env vars;)
FROM yoshz/ghost

# Add in our theme files
RUN mkdir -p /ghost/content/themes
ADD readium /ghost/content/themes/readium

# Here we symlink to /data, where we'll obtain shared storage from our sync container
RUN ln -s /data /ghost/content/images


