default: clear
	@echo
	@echo Please use one of the following options:
	@echo
	@echo '	hw	local	erf  	callbak		'
	@echo '	jaxh	odd42  	winjaph	eval		'
	@echo '	math	odd53  	gtk   			'
	@echo '	int    	float	event1			'
	@echo '	write   struct	event2			'
	@echo
	@echo '	hw	lost	snake	usages	PERL	'
	@echo '	hf	winjaph	square	HW	java	'
	@echo '	len	local  	square2	HP		'
	@echo '	write  	oopc	asm	HCW		'
	@echo
	@echo '	primes	seg	crash	knuth	'
	@echo '	muenzer	1-japh	1-jaxh	'
	@echo

test: hw jaxh math int write local odd42 odd53 float struct erf callbak eval \
      hf len write lost oopc snake square asm usages HW HP HCW PERL \
      seg crash knuth muenzer 1-japh 1-jaxh square2  

cache: int write local odd42 odd53 float struct erf callbak eval \
      lost oopc usages \
      muenzer 1-japh 1-jaxh 

#
# These commands are for running programs
#
hw: clear prompt
	perl bin/hello_world.pl

jaxh: clear prompt
	perl bin/JAxH.pl

math: clear prompt
	-perl bin/math.pl

int: clear prompt
	perl bin/int.pl

write: clear prompt
	perl bin/writable.pl

local: clear prompt
	perl bin/localtime.pl

odd42: clear prompt
	perl bin/odd.pl 42

odd53: clear prompt
	perl bin/odd.pl 53

float: clear prompt
	perl bin/float.pl

struct: clear prompt
	-perl bin/struct.pl

erf: clear prompt
	perl bin/erf.pl

winjaph: clear prompt
	-perl bin/WinJAPH.pl

gtk: clear prompt
	-perl bin/gtk.pl

event1: clear prompt
	-perl bin/event1.pl

event2: clear prompt
	-perl bin/event2.pl

callbak: clear prompt
	perl bin/callback.pl

eval: clear prompt
	perl bin/eval.pl





hf: clear prompt
	perl bin/hello_foo.pl

len: clear prompt
	perl bin/length.pl /usr/dict/words

lost: clear prompt
	perl bin/lostfound.pl

oopc: clear prompt
	perl bin/oopc.pl

snake: clear prompt
	perl bin/snake.pl Perl
	@perl -e 'print "> "'
	perl bin/snake.pl Python

square: clear prompt
	perl bin/squarer.pl

square2: clear prompt
	perl bin/yasquarer.pl

asm: clear prompt
	perl bin/asm_japh.pl

usages: clear prompt
	perl bin/01usages.t

PERL: clear prompt
	perl bin/PERL.pl

HW: clear prompt
	bin/Hello_World.cpr

HP: clear prompt
	bin/Hello_Perl.cpr

HCW: clear prompt
	bin/Hello_Cruel_World.cpr





cartoon: clear prompt
	perl bin/cartoons.pl data/cartoons.txt

badtoon: clear prompt
	perl bin/cartoons.pl

global: clear prompt
	perl bin/global.pl

oopc++: clear prompt
	perl bin/cpp.pl

rules: clear prompt
	perl bin/rules.pl

java: clear prompt
	perl bin/java-japh.pl

#
# These commands are for shortcuts
#
version: clear prompt
	perl -MInline=VeRsIoN

force: clear prompt
	perl -MInline=force bin/asmjaph.pl

taint1: clear prompt
	perl -wT bin/hello_world.pl

taint2: clear prompt
	perl -wT -MInline=untaint bin/hello_world.pl

taint3: clear prompt
	sudo perl -wT -MInline=untaint bin/hello_world.pl

taint4: clear prompt
	sudo perl -wT -MInline=untaint,unsafe bin/hello_world.pl

#
# These are for one-liners
#
primes: clear prompt
	perl -le 'while(($$_||=1)++){print if(1x$$_)!~/^(11+)\1+$$/}'

seg: clear prompt
	-perl5.6.0 -segfault{}

crash: clear prompt
	-perl -e 'require DynaLoader;DynaLoader::dl_install_xsub("main::hangme",unpack("I", pack("P4", "\xF0\x0F\xC7\xC8")));hangme()'

knuth: clear prompt
	perl -e 'BEGIN{my$$x="Knuth heals rare project\n";$$^H {integer}=sub{my$$y=shift;$$_=substr$$x=>$$y&0x1F,1;$$y>32?uc:lc};$$^H=hex join""=>2,1,1,0,0}print 52,2,10,23,16,8,1,20,3,6,15,12,5,49,21,14,9,11,36,13,22,32,7,18,24;'

1-japh: clear prompt
	perl -e 'use Inline C=>q{void J(){printf("Just Another Perl Hacker\n");}};J'

1-jaxh: clear prompt
	perl -le 'use Inline C=>q{SV*JAxH(char*x){return newSVpvf("Just Another %s Hacker",x);}};print JAxH+Perl'

muenzer: clear prompt
	perl -e 'use Inline C=>q{void C(){int m,u,e=0;float l,_,I;for(;1840-e;putchar((++e>907 &&942>e?61-m:u)["\n)moc.isc@rezneumb(rezneuM drahnreB"]))for(u=_=l=0;79-(m =e%80)&&I*l+_*_<6&&26-++u;_=2*l*_+e/80*.09-1,l=I)I=l*l-_*_-2+m/27.;}};&C'

#
# These are utility commands
#
clear:
	clear

prompt:
	@perl -e '$$|=1;print "\n> "'

sleep:
	@perl -e 'sleep 3'

purge: clean
	@rm -fr _Inline .cpr

clean:
	@rm -f *~ bin/*~ foo perl.exe.stackdump core

vi:
	@vi Makefile

prep:
	find .Inline -type d| grep hello_world | xargs rm -fr
	find .Inline -type d| grep JAxH | xargs rm -fr
	find .Inline -type d| grep math | xargs rm -fr
