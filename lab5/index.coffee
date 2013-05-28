window.root_routes = ["", "#", "#!", "#!/"]

class MenuItem
	constructor: (@title, @route) ->
		@title = window.model.u @title
		@active = ko.computed =>
			hash = window.model.hash()
			return "active" if hash is @route
			return "active" if hash in root_routes and @route in root_routes
			""

class ViewModel
	constructor: ->
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
		@navigation = ko.observable
			menu: ko.observableArray [
				new MenuItem "home", "#!/"
				new MenuItem "top", "#!/top"
				new MenuItem "authors", "#!/authors"
			]
			right_menu: ko.observableArray [
				new MenuItem "search", "#!/search"
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
		@sectionFilter = ko.observable {}
		@authorHref = (index) => "#!/authors/#{index()}"

ko.bindingHandlers.i18n =
	init: (element, valueAccessor) ->
		value = window.model.u valueAccessor()
		changeValue = (value) ->
			$(element).text value
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
				# unless target[what]
				# 	target[what] = true
				return "btn active" if target[what]
				"btn"
		ko.applyBindingsToDescendants innerBindingContext, element
		binded = true
		return { controlsDescendantBindings: true }

ko.virtualElements.allowedBindings.route = true
ko.bindingHandlers.route = 
	init: (element, valueAccessor, allBindingsAccessor, viewModel, bindingContext) ->
		console.log "init called"
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
		bindingContext = bindingContext.extend paramObservables
		ko.applyBindingsToDescendants bindingContext, element
		conditionAccessor = ->
			console.log "#{window.model.hash()}", "#{regex}"
			console.log "checking: #{window.model.hash().match new RegExp regex}"
			return true if window.model.hash().match new RegExp regex
			false
		hashchange = (hash) ->
			console.log "changed"
			match = hash.match new RegExp regex
			if match
				to_extend = {}
				params.forEach (param, index) ->
					console.log param
					if match[index + 1]
						paramObservables[param[1..]] match[index + 1]
					else
						paramObservables[param[1..]] ""
				paramObservables.matches true
			else
				paramObservables.matches false
			console.log bindingContext
		window.model.hash.subscribe hashchange
		hashchange window.location.hash
		{ controlsDescendantBindings: true }



ko.applyBindings new ViewModel
$("body").css
	display: "inherit"
