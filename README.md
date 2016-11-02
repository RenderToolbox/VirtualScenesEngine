# VirtualScenesEngine
Leverage VirtualScenesAssets into myriad scenes that we can render and analyze.

This is a work in progress.  Description etc coming soon.

# Design Notes
For now, here are some initial design notes.

## What is VirtualScenesEngine For?

The goal of VirtualScenesEngine is to leverage our VirtualScenesAssets into myriad virtual scenes that we can manipulate, render, and analyze.

Assimp/mexximp helps us load, manipulate, and interrogate our 3D model assets.  Assimp/mexximp also helps us combine multiple models into one struct and add things like lights and cameras.

So, one leverage factor comes from re-combining models to produce various mexximp structs.

Want some pictures of re-combined models under "boring" rendering.

VSE adds the concept of a "Style" which is orthogonal to the 3D model. Style includes materials and light spectra that can be applied to the model, as well as renderer configuration, like how to ray-sample the scene (which is often tightly coupled to the materials and lights that are used).

To keep style separable from models, style values are "cycled" over elements of a model.  For example, imagine a model that contains lots of materials, and a style that defines only a few.  When the style is applied to the model, the materials in the style are re-cycled from the beginning until they cover all materials in the model.  The same cycling idea applies to lights and light spectra, as well as materials.

This cycling approach should support full control over style values that are assigned to model elements: as long as the numbers match, the assignments will go one-to-one.  It should also support concise and reusable style definitions based on one or a few values.

So, an additional leveraging factor comes from crossing models with styles to produce various combos.

Want some pictures of the same model rendered with different styles.

VirtualScenesEngine is intended to work with RenderToolbox4.  3D models are loaded using Assimp and mexximp, which RenderToolbox4 supports.  Styles are expressed as RenderToolbox4 struct arrays very similar to RenderToolbox4 mappings.  Models and styles can be combined with RenderToolbox "hints", to produce complete RenderToolbox recipes.

## Model

any plain old mexximp scene struct, by any means

## Style

Data
 - Style name
 - renderer config mappings
 - material mappings to cycle over materials
 - mesh bless selector to cycle over meshes
 - illuminant spectra to cycle over blessed meshes

Operations
 - Util to make a well-formed Style struct
 - Util to make an all-matte Style struct from diffuse reflectances
 - Util to make an all-black-or-uniform-emitter Style struct

## Combo

Data
 - Combo name
 - Model struct
 - Style struct

Operations
 - Util to make a well-formed Combo struct

## VirtualScene

Data
 - VirtualScene name
 - outer Combo
 - inner Combos
 - inner Combo transformations

Operations
 - Util to make a well-formed VirtualScene struct.  Inner optional.

## RenderToolbox4

Operations
 - Util to make a Recipe from a VirtualScene plus hints.  Auto conditions and mappings files.
Leave remodeler functions open and optional for the user.
 - Utils to get renderer config mappings for quick, full, factoid, etc.

## General Keep-in-Mind

Use MipInputParser to access prefs instead of getpref(). This way prefs can always be overridden on the call stack, without messing up global Matlab state.

Ignore most current Collada model metadata in favor of scene struct.  Also, TODO, clean up those assets!

Save VirtualScene mexximp struct as recipe resource mat file. Support mat files for parent scenes in rtbMakeSceneFiles().

## Questions to Self

How to deal with factoids? Move to RTB4 itself. As a separate RTB4 renderer?  As an RTB4 util?

Is it OK for RTB4 mappings to invade the style part of VSE? Is it worth keeping the mappings out of VSE until actual recipe creation? I think it's not that big a deal after all. Use struct arrays that are relatively innocent, but trivial to convert to mappings.
