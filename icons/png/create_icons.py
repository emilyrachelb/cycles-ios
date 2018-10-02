#   Filename:       create_icons.py
#   Author:         Samantha Emily-Rachel Belnavis
#   Date:           September 19, 2018
#
#   License:        MIT
#   Description:    Generates png files from svg files

import os
import json

# directory locations
DIRECTORY = ["regular/black", "regular/white", "solid/black", "solid/white"]
for i in range(0, len(DIRECTORY)):
    list_dir = os.listdir(DIRECTORY[i])
    asset_catalog = "../Assets.xcassets/{}".format(DIRECTORY[i])
    print("asset catalog root: {}". format(asset_catalog))
    # create main asset directory
    os.system("mkdir -p {}".format(asset_catalog))

    for x in range(0, len(list_dir)):
        filename = list_dir[x]
        print("filename: {}".format(filename))

        assetname = filename.split('.')[0] + ".imageset"
        print("asset name: {}".format(assetname))

        filepath_1x = DIRECTORY[i] + "/" + list_dir[x]
        print("1x asset: {}".format(filepath_1x))

        filepath_2x = DIRECTORY[i] + "/2x/" + list_dir[x].split('.')[0] + "_2x.png"
        print("2x asset: {}".format(filepath_2x))

        filepath_3x = DIRECTORY[i] + "/3x/" + list_dir[x].split('.')[0] + "_3x.png"
        print("3x asset: {}\n".format(filepath_3x))

        contents = {
            "images": [
                {
                    "idiom": "universal",
                    "filename": filename,
                    "scale": "1x",
                },
                {
                    "idiom": "universal",
                    "filename": filename.split('.')[0] + "_2x.png",
                    "scale": "2x",
                },
                {
                    "idiom": "universal",
                    "filename": filename.split('.')[0] + "_3x.png",
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

        # create the directory to store the icon as an asset
        os.system('mkdir -p ../Assets.xcassets/{}/{}'.format(DIRECTORY[i], assetname))
        os.system('cp {} ../Assets.xcassets/{}/{}'.format(filepath_1x, DIRECTORY[i], assetname))
        os.system('cp {} ../Assets.xcassets/{}/{}'.format(filepath_2x, DIRECTORY[i], assetname))
        os.system('cp {} ../Assets.xcassets/{}/{}'.format(filepath_3x, DIRECTORY[i], assetname))

        with open("../Assets.xcassets/{}/{}/Contents.json".format(DIRECTORY[i], assetname), "w") as f:
            json.dump(contents, f)

