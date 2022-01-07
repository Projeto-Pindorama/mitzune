# Mitzune - chroot environments, for poor lads who don't have VMX support on
# their processors
This is just a prototype that I'm using to test Copacabana Linux on my PC via
chroot(8) since I don't have support to VMX in my low-end 10-year-old processor.
Yeah, fuck you Intel, People's Republic of China, TSMC and modern car manufacturers.
And fuck you too, Brazil gov't. I don't deserve being smashed by taxes and 
inflation and don't getting any nearly decent state services back.

So while I can't afford a new laptop, I will use this.
If this succeeds, I will remake it in Go, with faggotries like JSON for configu
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
It supports extracting gzip and xz'd files-- I don't think you would need
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

# How do I install it?
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

## Dependencies
• GNU Broken-Again Shell;
• OpenDoas --- for privilege elevation;
• The classical standard Unix utilities --- how far I've tested only Plan 9's
  give some odd bugs, otherwise, all the others tend to work perfectly;
• Any tar implementation --- I recommend using star;
• xz and gzip --- I recommend using pigz instead of gzip, since it's fairly
  faster.

## Get Mitzune
Releases and VCS snapshots can be found at get.pindorama.dob.jp.
http://get.pindorama.dob.jp/mitzune

# How do I use it?
There's a print_help function containing information about the basic usage.
For now, I didn't wrote a manual yet, so you will need to read the code to know
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
2010 (the 8th edition) can be found in some site whose name sounds like
"doceiro" (the portuguese word for "confectioner").

Although Bash is used here, I prefer the Korn Shell syntax for the most part of
things. I just didn't ported Mitzune 100% for Korn Shell yet because of other
things, such as getopt doesn't working the same.

# Who can I blame for it?
Me, Luiz Antonio (a.k.a takusuman).

## Who wrote these libraries?
errhand.shi was written entirely by me. As its name already says, it's meant
to be a simple error handling library. It is meant to be used in Mitzune, but
you can fork it and hack it to work as you want in your script (see "Hacking"
above).

posix-alt.shi, as I said below, was taken from my old, badly-written and
defunct project, otto-pkg --- and, because of that, it isn't on MIT, but in
the Caldera License --- and resurrected into something useful.
It is a collection of copycenter-licensed (MIT, BSD etc) Shell functions
from other hackers across the 'Net and, in majority, our own authoral work.
Since this "read me" is somewhat also Mitzune's documentation, I'll credit
everyone that some piece of work on it:
• realpath(), timeout(), nproc() and n() by Luiz Antonio;
• n() written originally by Luiz Antonio (as said above), rewritten from
scratch (and fixed) by Caio Yoshimura in September 2021;
• basename() and lines() from Araps' pure-sh-bible;
• lines() was incorporated by Caio Yoshimura, originally from Araps'
pure-sh-bible, line counter fixed by Luiz Antonio in June 2021.

# How can I share it?
This is under the MIT license, enjoy it. :^)
lib/posix-alt.shi is licensed under Caldera License, as it was taken from
otto-pkg, one of my first projects.

Footnote[0]: "Mitzune" is a pun on the name "Mitsune Konno", which is a
character from Ken Akamatsu's "Love Hina".
Mitsune is a beautiful young woman who have voluptuous foxy eyes, and a light
brown, short/boyish (and somewhat fluffy) hair. She likes drinking sake,
gambling and causing mischief when she's bored, but she never goes over the
limit.
The only affiliation between me, Kodansha (manga publisher) and Ken Akamatsu
is that I'm a big fan of his works.

Footnote[1]: Yeah, I've already got a new laptop, but I won't give up on
Mitzune. Besides Copacabana build consolidation already depending on it, I know
that are people over there with old and low-end PCs that may will need it in the
future.
