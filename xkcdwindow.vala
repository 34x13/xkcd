/***
The MIT License (MIT)

Copyright (c) 2014 Dracoscha

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
***/

public class XKCDWindow : Granite.Widgets.LightWindow {

	Gtk.Image image;

	public XKCDWindow(string url) {
		title = "xkcd";
        Gtk.EventBox container = new Gtk.EventBox ();
        add (container);
        set_position(Gtk.WindowPosition.CENTER_ALWAYS);

        image = new Gtk.Image ();
        container.add(image);

		load(url);

		destroy.connect (Gtk.main_quit);
		container.button_press_event.connect((e) => {
			load("http://c.xkcd.com/random/comic/");
			return false;
		});

	}

	public void load(string url) {
		var web_page = File.new_for_uri (url);
		//if (web_page.query_exists ()) {
			try {
				var dis = new DataInputStream (web_page.read ());
				string line;
				while ((line = dis.read_line (null)) != null) {
					//Very dirty code, you need a shower after that
					if(line.contains("id=\"comic\"")) {
						if((line = dis.read_line (null)) != null) {
							string[] elements = line.split("\"");
							title = "xkcd - "+elements[5];
							Gdk.Pixbuf pixbuf = pixbuf_from_web(elements[1]);
							pixbuf.add_alpha(true,255,255,255);//white -> transparent
							image.set_from_pixbuf(pixbuf);
							image.set_tooltip_text(elements[3]);
							icon = pixbuf;
						}
						break;
					}
				}
			} catch (Error e) {
				return;
			}
		//}
		show_all ();
	}

	private static Gdk.Pixbuf pixbuf_from_web(string uri) {
		File web_image = File.new_for_uri (uri);
		if (web_image.query_exists ()) {
		    try {
				DataInputStream dis = new DataInputStream (web_image.read ());
				return new Gdk.Pixbuf.from_stream(dis);
			} catch (Error e) {
				error ("%s", e.message);
			}
		}
		return null;
	}

	private static void main(string[] args) {
		Gtk.init (ref args);
		string url = "http://www.xkcd.com/";
		if(args.length>1)
			url = args[1];
		var win = new XKCDWindow(url);
		win.show_all();
		Gtk.main ();
	}
}
