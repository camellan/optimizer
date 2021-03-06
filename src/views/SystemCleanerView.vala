/* SystemCleanerView.vala
 *
 * Copyright 2019 Hannes Schulze
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

using Optimizer.Configs;
using Optimizer.Widgets;

namespace Optimizer.Views {

    /**
     * The {@code SystemCleanerView} class.
     *
     * @since 1.0.0
     */
    public class SystemCleanerView : Gtk.Overlay {
        private Gtk.Grid              main_grid;
        private Granite.Widgets.Toast toast;
        private Granite.Widgets.Toast result_toast;
        private Gtk.CheckButton       trash_checkbox;
        private Gtk.CheckButton       application_caches_checkbox;
        private Gtk.CheckButton       application_logs_checkbox;
        private Gtk.CheckButton       crash_reports_checkbox;
        private Gtk.CheckButton       package_caches_checkbox;

        /**
         * Constructs a new {@code SystemCleanerView} object.
         */
        public SystemCleanerView () {
            toast = new Granite.Widgets.Toast ("");
            result_toast = new Granite.Widgets.Toast ("");
            add_overlay (toast);
            add_overlay (result_toast);

            main_grid = new Gtk.Grid ();
            main_grid.halign = Gtk.Align.CENTER;
            main_grid.valign = Gtk.Align.CENTER;
            main_grid.column_homogeneous = true;
            main_grid.column_spacing = 36;
            main_grid.row_spacing = 12;
            main_grid.expand = true;
            add (main_grid);

            // Package Caches
            var package_caches_icon = new Gtk.Image ();
            package_caches_icon.gicon = new ThemedIcon ("package-x-generic");
            package_caches_icon.pixel_size = 64;
            main_grid.attach (package_caches_icon, 0, 0, 1, 1);

            var package_caches_label = new Gtk.Label (_("Package Caches"));
            package_caches_label.halign = Gtk.Align.CENTER;
            main_grid.attach (package_caches_label, 0, 1, 1, 1);

            package_caches_checkbox = new Gtk.CheckButton ();
            package_caches_checkbox.halign = Gtk.Align.CENTER;
            main_grid.attach (package_caches_checkbox, 0, 2, 1, 1);

            // Crash Reports
            var crash_reports_icon = new Gtk.Image ();
            crash_reports_icon.gicon = new ThemedIcon ("dialog-error");
            crash_reports_icon.pixel_size = 64;
            main_grid.attach (crash_reports_icon, 1, 0, 1, 1);

            var crash_reports_label = new Gtk.Label (_("Crash Reports"));
            crash_reports_label.halign = Gtk.Align.CENTER;
            main_grid.attach (crash_reports_label, 1, 1, 1, 1);

            crash_reports_checkbox = new Gtk.CheckButton ();
            crash_reports_checkbox.halign = Gtk.Align.CENTER;
            main_grid.attach (crash_reports_checkbox, 1, 2, 1, 1);

            // Application Logs
            var application_logs_icon = new Gtk.Image ();
            application_logs_icon.gicon = new ThemedIcon ("text-x-generic");
            application_logs_icon.pixel_size = 64;
            main_grid.attach (application_logs_icon, 2, 0, 1, 1);

            var application_logs_label = new Gtk.Label (_("Application Logs"));
            application_logs_label.halign = Gtk.Align.CENTER;
            main_grid.attach (application_logs_label, 2, 1, 1, 1);

            application_logs_checkbox = new Gtk.CheckButton ();
            application_logs_checkbox.halign = Gtk.Align.CENTER;
            main_grid.attach (application_logs_checkbox, 2, 2, 1, 1);

            // Application Caches
            var application_caches_icon = new Gtk.Image ();
            application_caches_icon.gicon = new ThemedIcon ("application-x-executable");
            application_caches_icon.pixel_size = 64;
            main_grid.attach (application_caches_icon, 3, 0, 1, 1);

            var application_caches_label = new Gtk.Label (_("Application Caches"));
            application_caches_label.halign = Gtk.Align.CENTER;
            main_grid.attach (application_caches_label, 3, 1, 1, 1);

            application_caches_checkbox = new Gtk.CheckButton ();
            application_caches_checkbox.halign = Gtk.Align.CENTER;
            main_grid.attach (application_caches_checkbox, 3, 2, 1, 1);

            // Trash
            var trash_icon = new Gtk.Image ();
            trash_icon.gicon = new ThemedIcon ("user-trash-full");
            trash_icon.pixel_size = 64;
            main_grid.attach (trash_icon, 4, 0, 1, 1);

            var trash_label = new Gtk.Label (_("Trash"));
            trash_label.halign = Gtk.Align.CENTER;
            main_grid.attach (trash_label, 4, 1, 1, 1);

            trash_checkbox = new Gtk.CheckButton ();
            trash_checkbox.halign = Gtk.Align.CENTER;
            main_grid.attach (trash_checkbox, 4, 2, 1, 1);

            // Clean Up button
            var clean_up_button = new Gtk.Button.with_label (_("Clean Up"));
            clean_up_button.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
            clean_up_button.halign = Gtk.Align.CENTER;
            clean_up_button.margin_top = 24;
            clean_up_button.clicked.connect (clean_up);
            main_grid.attach (clean_up_button, 0, 3, 5, 1);
        }

        private void clean_up () {
            string[] selected_folders = {};
            bool needs_root = false;

            if (package_caches_checkbox.active) {
                needs_root = true;
                selected_folders += "/var/cache/apt/archives/*.deb";
            }
            if (crash_reports_checkbox.active) {
                needs_root = true;
                selected_folders += "/var/crash/*.crash";
            }
            if (application_logs_checkbox.active) {
                needs_root = true;
                selected_folders += "/var/log/*";
            }
            if (application_caches_checkbox.active) {
                selected_folders += Path.build_filename (Environment.get_home_dir (), ".cache/*");
            }
            if (trash_checkbox.active) {
                selected_folders += Path.build_filename (Environment.get_home_dir (), ".local/share/Trash/files/*");
                selected_folders += Path.build_filename (Environment.get_home_dir (), ".local/share/Trash/info/*.trashinfo");
            }

            if (selected_folders.length > 0) {
                // TODO: Calculate disk space
                var message_dialog = new Granite.MessageDialog.with_image_from_icon_name (_("Do you want to continue?"),
                    _("This will delete the following files:"),
                    "dialog-warning",
                    Gtk.ButtonsType.CANCEL);
                message_dialog.width_request = 600;

                var continue_button = new Gtk.Button.with_label (_("Continue"));
                continue_button.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                message_dialog.add_action_widget (continue_button, Gtk.ResponseType.ACCEPT);

                var files_list = new Gtk.TextView ();
                files_list.border_width = 6;
                files_list.editable = false;
                files_list.pixels_below_lines = 3;
                files_list.wrap_mode = Gtk.WrapMode.WORD;
                files_list.width_request = 300;
                foreach (string folder in selected_folders) {
                    if (files_list.buffer.text != "") {
                        files_list.buffer.text += "\n";
                    }
                    files_list.buffer.text += folder;
                }

                var expander = new Gtk.Expander (_("Details"));
                expander.add (files_list);
                message_dialog.custom_bin.add (expander);

                message_dialog.show_all ();
                if (message_dialog.run () == Gtk.ResponseType.ACCEPT) {
                    toast.title = _("Deleting selected files...");
                    toast.send_notification ();
                    remove_files (selected_folders, needs_root);
                }
                message_dialog.destroy ();
            } else {
                toast.title = _("No items selected");
                toast.send_notification ();
            }
        }

        private void remove_files (string[] files, bool needs_root) {
            string[] spawn_args = {};
            if (needs_root) {
                spawn_args += "pkexec";
            }
            spawn_args += "sh";
            spawn_args += "-c";

            string[] new_files = { };
            foreach (var file in files) {
                if (!check_empty (file)) {
                    new_files += file;
                }
            }
            if (new_files.length == 0) {
                result_toast.title = _("Finished cleaning up with no errors");
	            result_toast.send_notification ();
                return;
            }
            spawn_args += "rm -r " + string.joinv (" ", new_files);

            string[] spawn_env = Environ.get ();
            Pid child_pid;

            try {
                int standard_input;
		        int standard_output;
		        int standard_error;

		        Process.spawn_async_with_pipes ("/",
			        spawn_args,
			        spawn_env,
			        SpawnFlags.SEARCH_PATH | SpawnFlags.DO_NOT_REAP_CHILD,
			        null,
			        out child_pid,
			        out standard_input,
			        out standard_output,
			        out standard_error);

		        // stderr:
		        IOChannel error = new IOChannel.unix_new (standard_error);
		        bool got_error = false;
		        error.add_watch (IOCondition.IN | IOCondition.HUP, (channel, condition) => {
		            if (condition == IOCondition.HUP) {
		                return false;
	                }

	                try {
		                string line;
		                channel.read_line (out line, null, null);
		                print ("Output on stderr while trying to delete files: %s", line);
		                got_error = true;
	                } catch (Error e) {
		                return false;
	                }

			        return true;
		        });

                ChildWatch.add (child_pid, (pid, status) => {
	                Process.close_pid (pid);
	                result_toast.title = _("Finished cleaning up %s").printf
	                    (got_error ? _("with errors!") : _("with no errors"));
	                result_toast.send_notification ();
                });
            } catch (SpawnError err) {
                stderr.printf ("Could not spawn command: %s\n", err.message);
            }
        }

        private bool check_empty (string path) {
            string[] spawn_args = { "sh", "-c", "ls %s".printf (path) };
            string[] spawn_env = Environ.get ();
            string ls_stdout;

            try {
                Process.spawn_sync ("/", spawn_args, spawn_env,
                    SpawnFlags.SEARCH_PATH | SpawnFlags.STDERR_TO_DEV_NULL,
                    null, out ls_stdout);

                if (ls_stdout.length > 0) {
                    return false;
                }
                return true;
            } catch (SpawnError err) {
                stderr.printf ("Spawn error: %s\n", err.message);
                return true;
            }
        }
    }
}
