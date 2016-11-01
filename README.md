# VirtualScenesEngine
Leverage VirtualScenesAssets into myriad scenes that we can render and analyze.

This is a work in progress.  Description etc coming soon.

# Design Notes
For now, here are some initial design notes.

## What is VirtualScenesEngine For?

The goal of VirtualScenesEngine is to leverage our VirtualScenesAssets into myriad virtual scenes that we can manipulate, render, and analyze.

Assimp/mexximp helps us load, manipulate, and interrogate our mesh geometry assets.  Assimp/mexximp also helps us combine multiple assets into one struct and add things like lights and cameras.

So, one leverage factor comes from re-combining assets to produce various mexximp structs.

Want some pictures of re-combined assets under "boring" rendering.

VSE adds the concept of a "Style" which is orthogonal to the assets. Style includes materials and light spectra that can be applied to the assets, as well as renderer configuration, like how to ray-sample the scene (which is often tightly coupled to the materials and lights that are used).

To keep style separable from assets, style elements are "cycled" over an asset struct.  For example, imagine an asset that contains lots of materials, and a style that defines only a few.  When the style is applied to the asset, the materials in the style are re-cycled from the beginning until they cover all materials in the asset.  The same cycling idea applies to lights and light spectra, as well as materials.

This cycling approach should support full control over style elements that are assigned to an asset: as long as the numbers match, the assignments will go one-to-one.  It should also support concise and reusable style definitions based on few elements, or just one.

So, an additional leveraging factor comes from crossing scenes with styles to produce 
various combos.

Want some pictures of the same assets rendered with different styles.

VirtualScenesEngine is intended to work with RenderToolbox4.  Assets and scenes are loaded loaded using Assimp and mexximp, which RenderToolbox4 supports.  Styles are expresset as RenderToolbox4 struct arrays very similar to RenderToolbox4 mappings.  Assets and styles can be combined with RenderToolbox "hints", to produce complete RenderToolbox recipes.

## Asset

any plain old mexximp scene struct, by any means

## Style

Style name
renderer config mappings
material mappings to cycle over materials
mesh bless selector to cycle over meshes
illuminant spectra to cycle over blessed meshes

Util to make a well-formed Style struct.
Util to make an all-mat Style struct from diffuse reflectances.
Util to make an all-black-or-uniform-emitter Style struct.

## Combo

Combo name
Asset struct
Style struct

Util to make a well-formed Combo struct

## VirtualScene

VirtualScene name
outer Combo
inner Combos
inner Combo transformations

Util to make a well-formed VirtualScene struct.  Inner optional.

## RenderToolbox4

Util to make a Recipe from a VirtualScene plus hints.  Auto conditions and mappings files.
Leave remodeler functions open and optional for the user.

Utils to get renderer config mappings for quick, full, factoid, etc.

## General Keep-in-Mind

Use MipInputParser to access prefs instead of getpref(). This way prefs can always be overridden on the call stack, without messing up global Matlab state.

Ignore most current Collada asset metadata in favor of scene struct.  Also, TODO, clean up the assets!

Save VirtualScene asset struct a recipe resource mat file. Support mat files for parent scenes in rtbMakeSceneFiles().

## Questions to Self

How to deal with factoids? Move to RTB4 itself. As a separate RTB4 renderer?  As an RTB4 util?

Is it OK for RTB4 mappings to invade the style part of VSE? Is it worth keeping the mappings out of VSE until actual recipe creation? I think it's not that big a deal after all. Use struct arrays that are relatively innocent, but trivial to convert to mappings.
