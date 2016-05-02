module.exports = 
  svg: (graph, x, y, options) ->
    width = parseInt(graph.getAttribute("width"))
    height = graph.getAttribute("height")
    @scale(@page.width / width) if width
    return (@_parseNode node for node in graph.children)

  _parseNode: (node, parent) ->
    switch node.nodeName
      when "svg"
        @_parseNode(node) for node in node.children
      when "g"
        @_parseG(node)
      when "rect"
        @_parseRect(node)
      when "line"
        @_parseLine(node)
      when "circle"
        @_parseCircle(node)
      when "path"
        @_parsePath(node)
      when "text"
        @_parseText(node)
      when undefined
        console.log("Undefined: " + node)
      else
        console.log("Unknown node type: " + node.nodeName)

  _parseG: (node) ->
    transform = node.getAttribute("transform")
    translate = @_getSvgTranslationValues(transform)
    @translate(translate[0], translate[1]) if translate
    @_parseNode(node) for node in node.children
    @translate(-translate[0], -translate[1]) if translate

  _parseRect: (node) ->
    width = node.getAttribute("width")
    height = node.getAttribute("height")
    x = node.getAttribute("x")
    y = node.getAttribute("y")
    fill = node.getAttribute("fill")
    stroke = @_getStroke(node)
    opacity = @_svgCalcOpacity(node)
    rect = @rect(x, y, width, height)
    rect.fillColor(fill, opacity).fill() unless fill == "none"
    rect.strokeColor(stroke, opacity).stroke() unless stroke == "none"

  _parseLine: (node) ->
    stroke = @_getStroke(node)
    x1 = node.getAttribute("x1")
    y1 = node.getAttribute("y1")
    x2 = node.getAttribute("x2")
    y2 = node.getAttribute("y2")
    opacity = @_svgCalcOpacity(node)
    @moveTo(x1, y1).
      lineTo(x2, y2).
      strokeColor(stroke, opacity).
      stroke()

  _parseCircle: (node) ->
    x = Math.round(parseFloat(node.getAttribute("cx")))
    y = Math.round(parseFloat(node.getAttribute("cy")))
    r = parseInt(node.getAttribute("r"))
    fill = node.getAttribute("fill")
    stroke = @_getStroke(node)
    opacity = @_svgCalcOpacity(node)
    unless fill == "none" and stroke == "none"
      circle = @circle(x, y, r)
      @_svgFillAndStroke(circle, fill, stroke, opacity)

  _parsePath: (node) ->
    fill = @_getFill(node)
    stroke = @_getStroke(node)
    lineWidth = parseInt(node.getAttribute("stroke-width"))
    d = node.getAttribute("d")
    opacity = @_svgCalcOpacity(node)
    return if d is null or d == ""

    @lineWidth(lineWidth) if !lineWidth.isNaN?
    unless fill == "none" and stroke == "none"
      path = @path(d)
      @_svgFillAndStroke(path, fill, stroke, opacity)

  _parseText: (node) ->
    x = Math.round(parseFloat(node.getAttribute("x")))
    y = Math.round(parseFloat(node.getAttribute("y")))
    transform = node.getAttribute("transform")
    textContent = node.textContent
    fontSize = window.getComputedStyle(node).getPropertyValue("font-size")
    fontSize = parseInt(fontSize)
    textAnchor = window.getComputedStyle(node).getPropertyValue("text-anchor")
    dominantBaseline = window.getComputedStyle(node).getPropertyValue("dominant-baseline")
    if dominantBaseline == "middle"
      y = y - (fontSize/2)
    fontWeight = window.getComputedStyle(node).getPropertyValue("font-weight")
    makeBold = (fontWeight == "bold" ||
                parseInt(fontWeight) > 600)

    rotate = @_getSvgRotationValues(transform)
    opacity = @_svgCalcOpacity(node)

    @fontSize(fontSize)
    if makeBold
      @font("Helvetica-Bold")
    else
      @font("Helvetica")
    @fillColor(@_getComputedFill(node), opacity)
    @fill
    @rotate(rotate[0], origin: [rotate[1], rotate[2]]) if rotate
    if textAnchor == "end"
      @text(textContent, x-100, y, width: 100, align: "right")
    else if textAnchor == "middle"
      @text(textContent, x-50, y, width: 100, align: "center")
    else
      @text(textContent, x, y, width: 100, align: "left")
    @rotate(- rotate[0], origin: [rotate[1], rotate[2]]) if rotate

  _getSvgRotationValues: (text) ->
    pattern = /rotate\(\d+,\s*\d+,\s*\d+\)/
    if pattern.test(text)
      rotate = text.match(pattern)[0]
      values = rotate.split("(")[1].split(")")[0].split(",")
      results = (Math.round(parseFloat(value)) for value in values)
    else
      results = undefined
    results

  _getSvgTranslationValues: (text) ->
    pattern = /translate\(\d+,\s*\d+\)/
    if pattern.test(text)
      translate = text.match(pattern)[0]
      values = translate.split("(")[1].split(")")[0].split(",")
      results = (Math.round(parseFloat(value)) for value in values)
    else
      results = undefined
    results

  _svgCalcOpacity: (node) ->
    opacity = node.getAttribute("opacity")
    if opacity is "" or opacity is null
      opacity = 1
    else
      opacity = parseFloat(opacity)
    return opacity

  _getStroke: (node) ->
    stroke = node.getAttribute("stroke")
    if stroke == ""
      return "none"
    else
      return stroke

  _getFill: (node) ->
    fill = node.getAttribute("fill")
    if fill == ""
      return "none"
    else
      return fill

  _svgFillAndStroke: (doc, fill, stroke, opacity) ->
    if fill != "none" and stroke != "none"
      doc.fillColor(fill, opacity).
          strokeColor(stroke, opacity).fillAndStroke()
    else
      soc.fillColor(fill, opacity).fill() unless fill == "none"
      doc.strokeColor(stroke, opacity).stroke() unless stroke == "none"
  _getComputedFill: (node) ->
    fill = window.getComputedStyle(node).getPropertyValue("fill")
    pattern = /rgb\(\d+,\s*\d+,\s*\d+\)/
    if pattern.test(fill)
      fill = fill.match(pattern)[0]
      values = fill.split("(")[1].split(")")[0].split(",")
      results = (Math.round(parseFloat(value)) for value in values)
    else
      results = "black"
    results

