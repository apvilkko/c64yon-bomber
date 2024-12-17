out.prg:
	cl65 -C ./c64custom.cfg -u __EXEHDR__ -o out.prg -l out.list src/main.asm

run: out.prg
	/usr/bin/flatpak run --branch=stable --arch=x86_64 --command=x64sc net.sf.VICE out.prg

clean:
	rm *.list *.prg