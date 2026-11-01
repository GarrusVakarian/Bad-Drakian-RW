SUBSYSTEM_DEF(librarian)
	name = "Librarian"
	init_order = INIT_ORDER_PLAYER_ARCHIVES
	flags = SS_NO_FIRE
	var/list/books = list()
	var/datum/player_archive/books/archive
	var/list/pending_random_books = list()

/datum/controller/subsystem/librarian/proc/get_book(input)
	if(!input)
		return list()
	if(books.Find(input))
		return books[input]
	books[input] = file2book(input)
	return books[input]

/proc/file2book(filename)
	if(!filename)
		return list()
	var/json_file = file("strings/books/[filename]")
	testing("filebegin")
	if(fexists(json_file))
		testing("file1")
		var/list/configuration = json_decode(file2text(json_file))
		var/list/contents = configuration["Contents"]
		if(isnull(contents))
			testing("file2")
			return list()
		return contents
	testing("file4")
	return list()

/datum/controller/subsystem/librarian/proc/playerbook2file(input, book_title = "Unknown", author = "Unknown", author_ckey = "Unknown", icon = "basic_book")
	if(!input)
		return "There is no text in the book!"
	if(fexists("data/player_generated_books/[url_encode(book_title)].json"))
		return "there is already a book by this title!"
	if(!(istext(input) && istext(book_title) && istext(author) && istext(author_ckey) && istext(icon)))
		return "This book is incorrectly formatted!"

	testing("playerbook2file1")
	var/list/contents = list("book_title" = "[book_title]", "author" = "[author]", "author_ckey" = "[author_ckey]", "icon" = "[icon]",  "text" = "[input]")
	//url_encode should escape all the characters that do not belong in a file name. If not, god help us
	var/file_name = "data/player_generated_books/[url_encode(book_title)].json"
	text2file(json_encode(contents), file_name)
	archive?.load_entries()

	if(fexists("data/player_generated_books/_book_titles.json"))
		testing("playerbook2file2")
		var/list/_book_titles_contents = json_decode(file2text("data/player_generated_books/_book_titles.json"))
		_book_titles_contents += "[url_encode(book_title)]"
		fdel("data/player_generated_books/_book_titles.json")
		text2file(json_encode(_book_titles_contents), "data/player_generated_books/_book_titles.json")
		message_admins("Book [book_title] has been saved to the player book database by [author_ckey]([author])")
		return "You have a feeling the newly written book will remain in the archive for a very long time..."
	else
		message_admins("!!! _book_titles.json no longer exists, previous book title list has been lost. making a new one without old books... !!!")
		text2file(json_encode(list(book_title)), "data/player_generated_books/_book_titles.json")
		return "_book_titles.json no longer exists, yell at your server host that some books have been lost!"

/datum/controller/subsystem/librarian/proc/file2playerbook(filename)
	if(!filename)
		return list()
	var/json_file = file("data/player_generated_books/[filename].json")
	testing("playerfilebegin")
	if(fexists(json_file))
		testing("playerfile1")
		var/list/contents = json_decode(file2text(json_file))
		if(isnull(contents))
			testing("playerfile2")
			return list()
		return contents
	testing("playerfile4")
	return list()

/datum/controller/subsystem/librarian/proc/del_player_book(book_title)
	testing("delplayerbook")
	if(!book_title)
		return FALSE
	var/json_file = file("data/player_generated_books/[book_title].json")
	if(!fexists(json_file))
		return FALSE
	if(fexists("data/player_generated_books/_book_titles.json"))
		fdel(json_file)
		var/list/_book_titles_contents = json_decode(file2text("data/player_generated_books/_book_titles.json"))
		_book_titles_contents -= "[book_title]"
		fdel("data/player_generated_books/_book_titles.json")
		text2file(json_encode(_book_titles_contents), "data/player_generated_books/_book_titles.json")
		archive?.load_entries()
		return TRUE
	else
		message_admins("!!! _book_titles.json no longer exists, previous book title list has been lost. !!!")
		return FALSE


/datum/controller/subsystem/librarian/proc/pull_player_book_titles()
	testing("pullplayerbook")
	if(fexists(file("data/player_generated_books/_book_titles.json")))
		var/json_file = file("data/player_generated_books/_book_titles.json")
		var/json_list = json_decode(file2text(json_file))
		return json_list
	else
		message_admins("!!! _book_titles.json no longer exists, previous book title list has been lost. !!!")

/datum/controller/subsystem/librarian/proc/amend_player_book(book_title, amend_type, amend_text)
	testing("amendplayerbook")
	if(!book_title || !amend_type || !amend_text)
		return FALSE
	if(fexists("data/player_generated_books/_book_titles.json"))
		var/list/contents = file2playerbook(book_title)
		del_player_book(book_title)
		contents[amend_type] = amend_text
		if(playerbook2file(contents["text"], book_title = contents["book_title"], author = contents["author"], author_ckey = contents["author_ckey"], icon = contents["icon"]) == "You have a feeling the newly written book will remain in the archive for a very long time...")
			return TRUE
		return FALSE
	else
		message_admins("!!! _book_titles.json no longer exists, previous book title list has been lost. !!!")
		return FALSE

/datum/controller/subsystem/librarian/Initialize(start_timeofday)
	archive = new
	return ..()

/datum/controller/subsystem/librarian/proc/stock_random_books()
	var/list/stock_callbacks = shuffle(pending_random_books)
	pending_random_books = list()
	for(var/datum/callback/stock as anything in stock_callbacks)
		stock.Invoke()

/datum/controller/subsystem/librarian/proc/archive_playerbook(obj/item/book/rogue/playerbook/book, mob/user)
	if(!book.player_book_text)
		player_archive_feedback(user, "There is no text in the book!")
		return FALSE
	var/file_name = archive.check_upload(user, book.player_book_title, book.get_contributor_ckeys())
	if(!file_name)
		return FALSE
	if(archive.is_title_taken(file_name))
		player_archive_feedback(user, "There is already a book by this title!")
		return FALSE
	var/category = book.player_book_category
	if(!(category in GLOB.player_book_categories))
		category = PLAYER_BOOK_DEFAULT_CATEGORY
	var/list/contents = list(
		"book_title" = "[book.player_book_title]",
		"author" = "[book.player_book_author]",
		"author_ckey" = "[book.player_book_author_ckey]",
		"icon" = "[book.player_book_icon]",
		"category" = "[category]",
		"text" = "[book.player_book_text]",
		"ic_date" = "[book.player_book_date || get_ic_date_short_as_string()]",
	)
	return archive.add_entry(file_name, contents, user)

/datum/controller/subsystem/librarian/proc/archive_player_book_titles(category, include_placed = FALSE)
	. = list()
	for(var/file_name in archive.get_usable_entries(include_placed))
		if(!category || archive.entries[file_name]["category"] == category)
			. += file_name

/datum/controller/subsystem/librarian/proc/amend_archived_player_book(filename, amend_type, amend_text)
	if(!istext(amend_text) || !length(trim(amend_text)) || !(amend_type in list("book_title", "author", "icon", "category")))
		return FALSE
	if(amend_type == "category" && !(amend_text in GLOB.player_book_categories))
		return FALSE
	var/list/contents = archive.entries[filename]
	if(!contents)
		return FALSE
	contents = contents.Copy()
	contents[amend_type] = amend_text
	var/new_file_name = filename
	if(amend_type == "book_title")
		new_file_name = player_archive_filename(amend_text)
		if(!new_file_name)
			return FALSE
		if(new_file_name != filename && archive.is_title_taken(new_file_name))
			return FALSE
	// Write the amended copy before removing the original so a failed save cannot lose the book.
	if(!archive.save_entry(new_file_name, contents))
		return FALSE
	if(new_file_name != filename)
		return archive.delete_entry(filename)
	return TRUE
