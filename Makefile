FLAGS = --thread --pkg gtk+-3.0 --pkg gio-2.0

FILES	=  xkcdwindow.vala

INSTALL = /usr/local/bin/


all:
	valac $(FLAGS) $(FILES) -o xkcd

clean:
	rm -rf xkcd *~ *.o ._*

test:
	./xkcd "http://xkcd.com/149/"

install: $(PROGS)
	cp xkcd $(INSTALL)/xkcd
	cp xkcd.desktop /usr/local/share/applications/xkcd.desktop

uninstall: $(PROGS)
	rm -f $(INSTALL)/xkcd
	rm -f /usr/local/share/applications/xkcd.desktop
	make removeautostart

addautostart:
	cp xkcd.desktop ~/.config/autostart/xkcd.desktop
removeautostart:
	rm -f ~/.config/autostart/xkcd.desktop
