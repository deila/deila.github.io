window.root_routes = ["", "#", "#!", "#!/"]

class MenuItem
	constructor: (@title, @route) ->
		@title = window.model.u @title
		@active = ko.computed =>
			hash = window.model.hash()
			return "active" if hash is @route
			return "active" if hash in root_routes and @route in root_routes
			""

# модель данных
class ViewModel
	constructor: ->
		# делаем модель глобальной и синглтоном (создается только 1 раз)
		# window.что-то — глобальная переменная
		# @ = this — текущий объект класса
		# обращение @что-то — this.что-то
		window.model = @
		@hash = ko.observable window.location.hash
		$(window).on "hashchange", => @hash window.location.hash
		@languages = languages
		@language = ko.observable "ru"
		@u = (to_translate) => ko.computed =>
			unless translations[@language()][to_translate]
				console.log "[warning] no translation: #{to_translate}"
				return to_translate
			translations[@language()][to_translate]	
		# ko — библиотека KnockoutJS
		# ko.observable — метод, возвращающий наблюдаемую переменную
		# JSON: объект в javascript
		# пример:
		# x = { hello: "world", a: 1, b: "ccca", inner: { bga: "test" } }
		# тоже, только красивее
		# x = {
		# 	hello: "world", 
		# 	a: 1, 
		# 	b: "ccca", 
		# 	inner: { 
		# 		bga: "test" 
		# 	} 
		# }
		# а в coffeescript:
		# x = 
		# 	hello: "world"
		# 	a: 1
		# 	b: "ccca"
		# 	inner:
		# 		bga: "test"
		@navigation = ko.observable
			menu: ko.observableArray [
				new MenuItem "home", "#!/"
				# new MenuItem "top", "#!/top"
				new MenuItem "authors", "#!/authors"
			]
			right_menu: ko.observableArray [
				# new MenuItem "search", @hash #"#!/search"
			]
		@title = @u "elibrary"
		@rootView = => @hash() in root_routes
		@route = (pattern) => @hash().match new RegExp pattern
		@sectionsActive = ko.observable false
		@toggleSections = => @sectionsActive !@sectionsActive()
		@enableSections = => @sectionsActive true
		@disableSections = => @sectionsActive false
		@foreach_by = (list, count) =>
			result = []
			local = []
			i = 0
			list.forEach (x) =>
				++i
				local.push x
				if i % count == 0
					result.push local
					local = []
			if local.length
				result.push local
			result
		@searchString = ko.observable ""
		@sectionFilter = ko.observable {}
		@authorsFiltered = ko.computed => 
			@hash window.location.hash
			data.authors.filter_by("name", @sectionFilter, { 'author.sections.in': 1, 'ko.computed.truekeys': 1 })()
				.filter_by("name", @searchString, { 'regex': 1, 'ko.computed': 1 })()
		@booksFiltered = ko.computed =>
			@hash window.location.hash
			data.books.filter_by("section", @sectionFilter, { 'book.in': 1, 'ko.computed.truekeys': 1 })()
				.filter_by("title", @searchString, { 'regex': 1, 'ko.computed': 1 })()
		@authorHref = (index) => "#!/authors/#{index}"
		@authorNext = (index) => ko.computed => 
			found = index()
			@authorsFiltered().forEach (x, i) => 
				if "#{x.id}" is "#{index()}"
					found = i
					found = parseInt(found) + 1
					found %= @authorsFiltered().length
			@authorHref @authorsFiltered()[found].id
		@authorPrev = (index) => ko.computed =>
			found = index()
			@authorsFiltered().forEach (x, i) => 
				if "#{x.id}" is "#{index()}"
					found = i
					found = parseInt(found) - 1
					found += @authorsFiltered().length
					found %= @authorsFiltered().length
			@authorHref @authorsFiltered()[found].id
		@author_active = ko.observable null
		@authorActiveComputed = {}
		@authorActive = (index) => 
			if @authorActiveComputed[index]
				return @authorActiveComputed[index]
			res = ko.computed =>
				x = @hash()
				return "active" if "#{@author_active()}" is "#{index}"
				""
			@authorActiveComputed[index] = res
			res
		@authorActivate = (index) => =>
			unless index
				return @author_active null
			@author_active index
		@authorHashByName = (author) =>
			for found in data.authors.filter_by "name", author
				return @authorHref found.id
			"#!/404"
		@book_hash = (id) => "#!/books/#{id}"
		@range = (a, b) => [a...b]
		@lorem = =>
			s = "<p>Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim eniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.</p>"
			res = []
			for i in @range 0, 30
				res.push s
			res.join ""
		@scrollToTop = =>
			setTimeout =>
				$("html, body").animate
					scrollTop: $("h3").offset().top - 20
			, 1

ko.bindingHandlers.i18n =
	init: (element, valueAccessor) ->
		value = window.model.u valueAccessor()
		changeValue = (value) ->
			$(element).text value
		changeValue value()
		value.subscribe changeValue

ko.bindingHandlers.i18nx =
	init: (element, valueAccessor) ->
		for k, v of valueAccessor().attr
			value = window.model.u v
			changeValue = (value) ->
				$(element).attr k, value
			changeValue value()
			value.subscribe changeValue

ko.bindingHandlers.do =
	init: (element, valueAccessor) ->
		todo = valueAccessor()
		todo()

ko.bindingHandlers.buttonFilter =
	init: (element, valueAccessor, allBindingsAccessor, viewModel, bindingContext) ->
		$element = $ element
		options = valueAccessor()
		target = options.target()
		for what in options.data
			unless target[what]
				target[what] = options.all
		options.target target
		binded = false
		innerBindingContext = bindingContext.extend 
			toggle: (what) -> -> 
				target = options.target()
				target[what] = !target[what]
				options.target target
			active: (what) -> ko.computed ->
				target = options.target()
				return "btn active" if target[what]
				"btn"
			toggleAll: ->
				all = true
				target = options.target()
				for k, v of target when v
					all = false
				for k, v of target
					target[k] = all
				options.target target
			anyActive: ->
				target = options.target()
				for k, v of target when v
					return "btn active"
				"btn"
		ko.applyBindingsToDescendants innerBindingContext, element
		binded = true
		return { controlsDescendantBindings: true }

ko.virtualElements.allowedBindings.route = true
ko.bindingHandlers.route = 
	init: (element, valueAccessor, allBindingsAccessor, viewModel, bindingContext) ->
		# ko route: "^#!/authors/:id$"
		truthy = -> -> true
		falsy = -> -> false
		regex = valueAccessor()
		params = regex.match /:[a-z_]+/g
		params = params or []
		regex = regex.replace /:[a-z_]+/g, "(.+)"
		paramObservables = { matches: ko.observable false }
		params.forEach (param) ->
			paramObservables[param[1..]] = ko.observable ""
		childBindingContext = bindingContext.createChildContext viewModel
		ko.utils.extend childBindingContext, paramObservables
		ko.applyBindingsToDescendants childBindingContext, element
		conditionAccessor = ->
			return true if window.model.hash().match new RegExp regex
			false
		hashchange = (hash) ->
			match = hash.match new RegExp regex
			if match
				to_extend = {}
				params.forEach (param, index) ->
					if match[index + 1]
						paramObservables[param[1..]] match[index + 1]
					else
						paramObservables[param[1..]] ""
				paramObservables.matches true
			else
				paramObservables.matches false
		window.model.hash.subscribe hashchange
		hashchange window.location.hash
		{ controlsDescendantBindings: true }



ko.applyBindings new ViewModel
$("body").css
	display: "inherit"
