window.data = 
	sections: []
	books: []
	sectionCounters: {}
	authors: []
	authorSections: {}

gkeys = (x) -> 
	key for key of x

truekeys = (x) ->
	key for key, value of x when value

Array.prototype.gkeys = -> @

Array.prototype.filter_by = (by_what, value, opts) ->
	wby = (x) -> x[by_what]
	unless by_what
		wby = (x) -> x
	unless opts
		return @filter (x) -> x[by_what] is value
	if opts["author.sections.in"]
		filter = (value) -> (x) -> 
			flag = false
			data.authorSections[wby x].forEach (y) -> 
				return if flag
				if y in value
					flag = true
			flag
	if opts["book.in"]
		filter = (value) -> (x) -> wby(x) in value
	if opts["regex"]
		filter = (value) -> (x) -> wby(x).match value
	if opts["ko.computed"]
		return ko.computed => @filter filter value()
	if opts["ko.computed.truekeys"]
		return ko.computed => @filter filter truekeys value()
	return @filter filter value

book_count = 0

class Book
	constructor: (@title, @author, @section) ->
		@id = book_count
		book_count += 1
		unless @author in data["authors"]
			data["authors"].push 
				name: @author
				id: data["authors"].length
			data["authorSections"][@author] = []
		unless @section in data["sections"]
			data["sections"].push @section
			data["sectionCounters"][@section] = 0
		unless @section in data["authorSections"][@author]
			data["authorSections"][@author].push @section
		data["sectionCounters"][@section] += 1

data["books"] = [
	new Book "1812 год", "Клаузевиц Карл", "history"
	new Book "Гибель волхва", "Осетров Н", "history"
	new Book "Если б заговорил сфинкс...", "Аматуни П", "history"
	new Book "Очерки Бородинского сражения", "Глинка Ф", "history"
	new Book "Чингиз-хан (книга 1, 2)", "Ян Василий", "history"
	new Book "Бомба №14", "Ричи Джек", "detective"
	new Book "Будь моим гостем", "Найт Дэймон", "detective"
	new Book "Вне закона", "Биварли Элизабет", "detective"
	new Book "Раритет Гильдебранда", "Флеминг Ян", "detective"
	new Book "Ритианский террор", "Найт Дэймон", "detective"
	new Book "Сборник детективов", "Стаут Рекс", "detective"
	new Book "Три рассказа в Гэллегере", "Каттнер Генри", "detective"
	new Book "Честная игра", "Кортес Джон", "detective"
	new Book "Бег по кругу", "Видар Гарм", "fantastic"
	new Book "В восемь утра", "Нельсон Рэй", "fantastic"
	new Book "Врата рая", "Стэблфорд Брайан", "fantastic"
	new Book "Космические инженеры", "Саймак Клиффорд", "fantastic"
	new Book "Линкор в нафталине", "Гаррисон Гарри", "fantastic"
	new Book "Пересечение Эйнштейна", "Дилани Сэмюэль", "fantastic"
	new Book "Поле боя", "Кинг Стивен", "fantastic"
	new Book "Сердце звездного мира", "Блиш Джеймс", "fantastic"
	new Book "Хранители", "Кристофер Джон", "fantastic"
	new Book "Шестая глава «Дон Кихота»", "Штерн Борис", "fantastic"
	new Book "Белый клык", "Лондон Джек", "adventures"
	new Book "Золота на ветру", "Тихомирова В", "adventures"
	new Book "Ким", "Киплинг Редьярд", "adventures"
	new Book "Кладоискатели", "Ирвинг Вашингтон", "adventures"
	new Book "Охотники на мамонтов", "Шторх Эдуард", "adventures"
	new Book "Последний из могикан", "Купер Джеймс", "adventures"
	new Book "Пятнадцатилетний капитан", "Верн Жюль", "adventures"
	new Book "Челюсти", "Бенчли Питер", "adventures"
	new Book "Великий закон доктора Строптизиуса", "Сергиевская Ирина", "humor"
	new Book "Веселый солдат", "Астафьев Виктор", "humor"
	new Book "Двенадцать стульев", "Ильф Илья", "humor"
	new Book "Мыльный роман", "Промптов А", "humor"
	new Book "Непричесанные мысли", "Лец Ежи", "humor"
	new Book "Оживление", "Исаев Максим", "humor"
	new Book "Срочное погружение", "Дрыжак Владимир", "humor"
	new Book "Трое в одном морге, не считая собаки", "Михайличенко Елизавета", "humor"
	new Book "Возьми в дорогу врача", "Соколов Кирилл", "lyrics"
	new Book "Глаз", "Моррисон Джим", "lyrics"
	new Book "Мертвый мороз", "Хенд Секонд", "lyrics"
	new Book "Поэмы", "Купала Янка", "lyrics"
	new Book "Стихи", "Киплинг Редьярд", "lyrics"
	new Book "Три порции соуса жизни", "Венский Э", "lyrics"
	new Book "Три яйца", "Ханинаев Виталий", "lyrics"
	new Book "Эссе, новеллы, стихи", "Зейгермахер Леонид", "lyrics"
]
