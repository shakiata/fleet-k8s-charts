#!/bin/bash

# Create a directory to store the downloaded files
DOWNLOAD_DIR="minecraft-plugins"
mkdir -p "$DOWNLOAD_DIR"

# List of URLs and their corresponding filenames
declare -A files=(
    ["https://ci.ender.zone/job/EssentialsX/lastSuccessfulBuild/artifact/jars/EssentialsX-2.21.0-dev+182-e49021f.jar"]="EssentialsX.jar"
    ["https://www.spigotmc.org/resources/bluemap-essentials.84365/download?version=509269"]="BlueMap-Essentials.jar"
    ["https://www.spigotmc.org/resources/coreprotect.8631/download?version=541095"]="CoreProtect.jar"
    ["https://www.spigotmc.org/resources/craftgpt.109639/download?version=516882"]="CraftGPT.jar"
    ["https://www.spigotmc.org/resources/customrecipeapi-1-13.74134/download?version=428223"]="CustomRecipeAPI.jar"
    ["https://download.luckperms.net/1573/bukkit/loader/LuckPerms-Bukkit-5.4.156.jar"]="LuckPerms-Bukkit.jar"
    ["https://www.spigotmc.org/resources/treefeller.84310/download?version=510446"]="TreeFeller.jar"
    ["https://www.spigotmc.org/resources/luckperms-gui-1-16-x-1-20-x.108831/download?version=509246"]="LuckPerms-GUI.jar"
    ["https://dev.bukkit.org/projects/worldedit/files/6122276"]="WorldEdit.jar"
    ["https://dev.bukkit.org/projects/worldguard/files/6201343"]="WorldGuard.jar"
)

# Download each file
for url in "${!files[@]}"; do
    filename="${files[$url]}"
    echo "Downloading $filename..."
    curl -L -o "$DOWNLOAD_DIR/$filename" "$url"
done

echo "All plugins downloaded to $DOWNLOAD_DIR."
