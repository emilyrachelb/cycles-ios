#   Filename:       create_icons.py
#   Author:         Samantha Emily-Rachel Belnavis
#   Date:           September 18, 2018
#
#   License:        MIT
#   Description:    Generates png files from svg files


import os
import json

# directory locations
DIRECTORY = ["regular/black", "regular/white", "solid/black", "solid/white"]
for i in range(0, len(DIRECTORY)):
    list_dir = os.listdir(DIRECTORY[i])
    asset_catalog = "assets/{}".format(DIRECTORY[i])

    # create main asset directory
    os.system("mkdir -p {}".format(asset_catalog))

    for file in range(0, len(list_dir)):
        filename = list_dir[file].split('.svg')[0] + ".imageset"
        file_location = "{}/{}.svg".format(DIRECTORY[i], filename)
        print("file location: {}".format(file_location))
        destination_file_1x = "{}/{}/{}.png".format(asset_catalog, filename, filename)
        destination_file_2x = "{}/{}/{}_2x.png".format(asset_catalog, filename, filename)
        destination_file_3x = "{}/{}/{}_3x.png".format(asset_catalog, filename, filename)

        destination_directory = "{}/{}".format(asset_catalog, filename)

        # create asset directory
        os.system("mkdir -p {}/{}".format(asset_catalog, filename))

        # template for the asset's contents.json
        contents = {
            "images": [
                {
                    "idiom": "universal",
                    "filename": "{}.png".format(filename),
                    "scale": "1x",
                },
                {
                    "idiom": "universal",
                    "filename": "{}_2x.png".format(filename),
                    "scale": "2x",
                },
                {
                    "idiom": "universal",
                    "filename": "{}_3x.png".format(filename),
                    "scale": "3x",
                }
            ],
            "info": {
                "version": 1,
                "author": "Samantha Emily-Rachel Belnavis"
            },
            "properties": {
                "compression-type": "gpu-optimized-best",
                "template-rendering-intent": "original",
                "preserves-vector-representation": True
            }
        }


        # create asset 1x
        os.system("convert -background transparent -size 18x18 {} \"{}\"".format(file_location, destination_file_1x))

        # create asset 2x
        os.system("convert -background transparent -size 36x36 {} \"{}\"".format(file_location, destination_file_2x))

        # create asset 3x
        os.system("convert -background transparent -size 54x54 {} \"{}\"".format(file_location, destination_file_3x))

        with open("{}/Contents.json".format(destination_directory), 'w') as f:
            json.dump(contents, f)