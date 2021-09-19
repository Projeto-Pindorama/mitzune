# Mitzune - """Pseudo-virtualization""" for poor lads who doesn't have VMX on 
# their processors
This is just a prototype that i'm using to test Copacabana Linux on my PC via
chroot(8) since i don't have support to VMX in my low-end 10-year-old processor.
Yeah, fuck you Intel, Republic of China, TSMC and modern car manufacturers.
And fuck you too, Brazil gov't. I don't deserve being smashed by taxes and 
inflation and don't getting any nearly decent state services back.

So while i can't afford a new laptop, i will use this.
If this succeeds, i will remake it in the cringiest language ever, Go, with
faggotries like JSON for configuration et cetera. And because Shell is fucking
ugly.

# What is the main idea?
I don't know yet, i'll be polishing for sure, but is that you have a prefix 
(~/mitzune) where you can extract/copy another operating system of same
architecture root files (which can be saved on an tarball) and then configure
it.
After that, in theory, you'd just need to run Mitzune + the operation + the
prefix name.

Example:
mitzune -n minilinux -R ~/Downloads/minilinux-rootfs-0.4.2a-x86_64.tar.xz -c

This will create a prefix with the name of "minilinux", using the
minilinux-rootfs-0.4.2a-x86_64.tar.xz as the tarball to be extracted.
You can also create a Shell-style configuration file using the -C option, but i
couldn't manage to get this working yet... :^|

It's basically containers made by someone who doesn't ever used containers
before.

This is sure to fail, i know it is.

# How do i install it?
I've designed it to be used as an user-local script, not system-wide.
You can install it using this pipeline, which extracts the tarball release from
xz and un-tar it directly to your home directory:

xz -cd mitzune.?.?-?.NOARCH.Linux.tar.xz | tar -xvf - -C ~/

But, before you ask me, this is a work in progress.
At this moment, 17th September 2021, you can not chroot into a "prefix" (i need a 
better name for this) using Mitzune, you'll need to do it manually; like you can't
map a prefix (using find(1) + xz(1) (for compressing it)) yet.

# How do i use it?
For now, i didn't wrote a manual or even the print_help function yet, so you will
need to read the code. Sorry... :^(
But, if you mind helping me, you can write a small text about the functions or
even the print_help function and pull-request-it.
I would be grateful. :^)

# Who can i blame for it?
Me, Luiz Antonio (a.k.a takusuman).

# How can i share it?
This is under the MIT license, enjoy it. :^)
lib/posix-alt.shi is licensed under Caldera License, as it was taken from
otto-pkg, one of my first projects.
