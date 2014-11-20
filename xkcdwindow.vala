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

public class XKCDWindow : Gtk.Window {

	Gtk.Image image;
	Gtk.HeaderBar headerbar;
	Gtk.ScrolledWindow scrolled;

	public XKCDWindow(string url) {
		this.title = "xkcd";
		//this.border_width = 10;

		headerbar = new Gtk.HeaderBar();
		headerbar.show_close_button = true;
		headerbar.set_title("xkcd");
		headerbar.set_subtitle("");
		this.set_titlebar(headerbar);

        Gtk.EventBox container = new Gtk.EventBox ();
        scrolled = new Gtk.ScrolledWindow (null, null);
		add (scrolled);
        scrolled.add (container);
        set_position(Gtk.WindowPosition.CENTER_ALWAYS);

        this.image = new Gtk.Image ();
        container.add(image);

		this.load(url);

		container.button_press_event.connect((e) => {
			load("http://c.xkcd.com/random/comic/");
			return false;
		});

		this.destroy.connect(Gtk.main_quit);

	}

	public void load(string url) {
		var web_page = File.new_for_uri (url);
		//if (web_page.query_exists ()) {
			try {
				var dis = new DataInputStream (web_page.read ());
				string line;
				while ((line = dis.read_line (null)) != null) {
					//Very dirty code ahead, you need a shower after that
					if(line.contains("id=\"comic\"")) {
						if((line = dis.read_line (null)) != null) {
							string[] elements = line.split("\"");
							//title = "xkcd - "+elements[5];
							headerbar.set_subtitle(elements[5]);
							Gdk.Pixbuf pixbuf = pixbuf_from_web(elements[1]);
							if(pixbuf==null) {
								load(url);
								return;
							}
							pixbuf.add_alpha(true,255,255,255);//white -> transparent
							image.set_from_pixbuf(pixbuf);
							update_decription(elements[3]);
							if(pixbuf.height<500) {
								this.scrolled.min_content_height = pixbuf.height+10;
								this.scrolled.min_content_width = pixbuf.width+10;
								this.resize(pixbuf.width+10,pixbuf.height+10);
							} else {
								this.scrolled.min_content_height = 350;
								this.scrolled.min_content_width = pixbuf.width+15;
								this.resize(pixbuf.width+15,450);
							}
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

	private void update_decription(string text) {
		string escaped_text = text.replace("&#39;","'");
		string[] words = escaped_text.split(" ");

		string final_text = "";
		int line_length = 0;
		foreach(string word in words) {
			if(line_length+word.length>40) {
				final_text += "\n";
				line_length = 0;
			}
			final_text += word+" ";
			line_length += word.length;
		}
		image.set_tooltip_text(final_text);
	}

	private static Gdk.Pixbuf? pixbuf_from_web(string uri) {
		File web_image = File.new_for_uri (uri);
		if (web_image.query_exists ()) {
		    try {
				DataInputStream dis = new DataInputStream (web_image.read ());
				return new Gdk.Pixbuf.from_stream(dis);
			} catch (Error e) {
				return null;
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
