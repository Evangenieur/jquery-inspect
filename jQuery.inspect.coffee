$.fn.inspect = (obj) ->
  
  class Inspect
    constructor: (@obj, @elem) ->
      @root = @createElem "div",
        class: 'inspector'
      @data = {}

      if @elem
        @attachTo @elem

      type = typeof @obj 
      if type is "object"
        if @obj.constructor?.name?
          type = @obj.constructor?.name

        type += " : #{@obj.toString()}"

      @createPanel @obj, $(@root), type
    
    createElem: (tag, attr, html) ->
      elem = document.createElement tag
      $(elem).attr(attr).html html
      elem

    id: (elem) ->
      id = elem.id
      return id if id
      for i in [0..5]
        id += "_"+Math.ceil(Math.random()*100000)
      elem.id = id

    attachTo: (elem) ->
      $(elem).append(@root)

    createPanel: (obj, container, title) ->
      panel = @createElem "ul",
        "class": "panel"
      #  "style": "display: none"
      if title?
        _title = $(@createElem "h1", "class": "paneltitle").html title
        $(panel).append _title
      $(container).append panel

      switch typeof obj
        when "object"
          for prop in Object.getOwnPropertyNames(obj)
            @createItem prop, obj[prop], panel
        else
          @createItem "", obj, panel

      #$(panel).slideDown 500

    createItem: (label, value, container) ->
      isExpandable = @isExpandable value
      item = @createElem "li", "class": "item"
      $(container).append item
      if isExpandable
        id = @id(item)
        icon = @createElem "span", "class": "expandIcon", "+"
        $(item).addClass("expandable").append(icon)
        @data[id] = value

      e_label = @createElem "span", {"class": "obj_label"}, label
      e_value = @createElem "span", {"class": "obj_value"}, @valueSummary value
      $(item).append e_label
      $(item).append e_value
      if isExpandable
        $(e_label).
          add(icon).
          add('.summary', e_value).
          add('.type', e_value).
          click( (e) =>
            @expandToggle $(e.currentTarget).parents('.item')[0], e
          ).css cursor: "pointer"

    isExpandable: (value) ->
      return false if typeof value isnt "object"
      !$.isEmptyObject value

    valueSummary: (value) ->
      name = ""
      if typeof value is "object"
        title= \
          if $.isArray value
            "array"
          else if $.isFunction value
            "function"
          else
            "object"
        summary = @objectSummary value
        name = """<span class="type">[#{title}]</span>"""
        if summary 
          name += """<span class="summary">#{summary}</span>"""
      else if typeof value is "function"
        span = document.createElement "span"
        $(span).text value.toString()
        name = $(span).html()
      else
        name = value
      name

    objectSummary: (obj) ->
      ("""#{k}:<span class="strong">#{v}</span>""" for k, v of obj).
        join " "

    expandToggle: (elem, e) ->
      e.stopPropagation()
      container = $(elem).find(".obj_value")[0]
      icon = $(elem).find(".expandIcon")[0]
      isExpanded = $(icon).hasClass "open"
      id = @id elem
      if isExpanded
        $(elem).find(".item").each ->
          if e.currentTarget.id
            delete @data[e.currentTarget.id]
        $(container).children(".panel").slideUp 100, "swing", ->
          $(@).remove()
        $(icon).removeClass("open").html "+"

      else
        $(@createPanel @data[id], container).slideDown 300, "swing"
        $(icon).addClass("open").html "-"

  $(@).each ->
    new Inspect obj, @
  @