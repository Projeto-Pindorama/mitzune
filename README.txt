# Mitzune[1] - chroot environments, for poor lads who don't have VMX support on
# their processors
This is just a prototype that i'm using to test Copacabana Linux on my PC via
chroot(8) since i don't have support to VMX in my low-end 10-year-old processor.
Yeah, fuck you Intel, People's Republic of China, TSMC and modern car manufacturers.
And fuck you too, Brazil gov't. I don't deserve being smashed by taxes and 
inflation and don't getting any nearly decent state services back.

So while i can't afford a new laptop, i will use this.
If this succeeds, i will remake it in Go, with faggotries like JSON for configu
ration et cetera. And because Shell is fucking ugly.

# What is the main idea?
The main idea is that you have a prefix (~/mitzune) where you can extract/copy
another UNIX-like (same-kernel, in case of a Linux host, of course) operating 
system of same architecture root files (which can be saved on an tarball) and 
then configure it.
After that, in theory, you'd just need to run Mitzune + the prefix name + the
operation.

Example:
mitzune -n copacabana -R ~/projects/copacabana_olinux-rootfs-0.4.2a-x86_64.tar.xz -c

This will create a prefix with the name of "copacabana", using the
copacabana_olinux-rootfs-0.4.2a-x86_64.tar.xz as the tarball to be extracted.
It supports extracting gzip and xz'd files-- i don't think you would need
anything else; if you feel the need to use anything else, like for example bzip2,
just pull-resquest it!

You can also create a Shell-style configuration file using the -C option, just
set it before -c(reate) or -r(un). 
Its contents will be sent into chroot's /etc/profile (if OVERWRITE_CHROOT_PROFILE 
is equal to "true") or into an identificable Mitzune file called mitzune_config.sh 
located at /etc/profile.d (if OVERWRITE_CHROOT_PROFILE is equal to "false" or 
anything else).

In Alpine Linux, you may need to source /etc/profile right after logging into it.
Kind of a fishy bug, but it works so... :^)

It's basically containers made by someone who doesn't ever used popular containers
before.

# How do i install it?
I've designed it to be used as an user-local script, not system-wide.
You can install it using this pipeline, which extracts the tarball release from
xz and un-tar it directly to your home directory:

xz -cd mitzune.?.?-?.NOARCH.Linux.tar.xz | tar -xvf - -C ~/

But, before you ask me, this is a work in progress.
At this moment, 17th October 2021, you can't map a prefix (using find(1) + 
xz(1) (for compressing it)) yet.
There's already an implementation for chrooting with Mitzune, but it's
experimental (polite word for "crappy") yet and needs some polishing, but hey,
it works! :^)

# How do i use it?
For now, i didn't wrote a manual yet, so you will need to read the code to know
better what happens under the table. Sorry... :^(
But, if you mind helping me, you can write a small text about the functions and
pull-request-it.
I would be grateful. :^)

## Hacking
Mitzune's code is fairly readable even for ones who doesn't actually program in
Shell Script, I've been also keeping a consistent and sane code-style (result of
years of experience being beaten by syntax errors or by reading my own code and
don't understanding it).

Good references for learning Shell Script for hacking Mitzune's code are the
"Advanced Bash-Scripting Guide", "Learning the Korn Shell, 2nd Edition" and, for
Portuguese language speakers, "Programação Shell Linux" --- which tries to teach
characteristics both from GNU Bourne-Again Shell, Korn Shell and some even from
the crappy POSIX standard.

The ABS can be found on TLDP.org, it's public domain! :^)
"Learning the Korn Shell" is a paid book, but can be found for free in some
"Milk (doc)store" from Ukraine.
"Programação Shell Linux" is also a paid book, but an older version from around
2010 (the 8th edition) can be found in some site whose name recalls "doceiro"
(the portuguese word for "confectioner").

Although Bash is used here, I prefer the Korn Shell syntax for the most part of
things. I just didn't ported Mitzune 100% for Korn Shell yet because of other
things, such as getopt doesn't working the same.

# Who can i blame for it?
Me, Luiz Antonio (a.k.a takusuman).

# How can i share it?
This is under the MIT license, enjoy it. :^)
lib/posix-alt.shi is licensed under Caldera License, as it was taken from
otto-pkg, one of my first projects.

Footnote[1]: "Mitzune" is a pun on the name "Mitsune", which is a character
from Ken Akamatsu's "Love Hina".
Mitsune is a young woman who have voluptuous foxy eyes, and a light brown,
short and somewhat fluffy hair. She likes to drink sake, gambling and
causing mischief when she's bored, but she never goes over the limit.

The only affiliation between me, Kodansha (manga publisher) and Ken Akamatsu
is that I'm a big fan of his works.
