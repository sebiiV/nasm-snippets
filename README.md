# NASM snippets

Getting more into assembly and finding the documentation and the the capability of MASM pretty limiting. Hence the switch to NASM.

> NASM is Intel syntax.
> OPERATION dst,src


# Project Setup
## Prequisites 
    NASM ‘compiler’ from its Home Site.
    VSNASM an open-source project to integrate it into Visual Studio from GitHub.

## Setting up Visual Studio

Start Visual Studio and:

    open ‘Tools‘->’Options…‘ window from the main menu.
    go to ‘Projects and Solutions‘ -> ‘VC++ Project Settings‘.
    set ‘Build Customization Search Path‘ with your NASM installation folder.
    confirm and exit.

The last step is to enable .asm support into your project.

    open your project.
    right-click each project using .asm files.
    select ‘Build Dependencies‘->’Build Customizations‘.
    check ‘nasm‘ option.
    confirm.

Then for each .asm file, you have to:

    open the file ‘Properties‘
    set into ‘General‘->’Item Type‘ to ‘Netwide Assembler‘ (or whatever you set, “NASM – Netwide Assembler” in my case).
    enable the debug information for the debug profile from the specific NASM options.
    confirm.

> NOTE: from this last property window, we can also set if to compile the file or not in 32/64 bits target platforms.

You may also need to change the entrypoint:
	
	Right click on the project and go to properties
	Under Linker --> Advanced you can change the Entry Point
	This is typically main
# Debugging

- winDBG 
- GHIDRA
