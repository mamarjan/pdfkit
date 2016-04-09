module.exports = 
  svg: (graph, x, y, options) ->
    width = graph.getAttribute("width")
    height = graph.getAttribute("height")
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
    stroke = node.getAttribute("stroke")
    opacity = @_svgCalcOpacity(node)
    rect = @rect(x, y, width, height)
    rect.fillColor(fill, opacity).fill() unless fill == "none"
    rect.strokeColor(stroke, opacity).stroke() unless stroke == "none"

  _parseLine: (node) ->
    stroke = node.getAttribute("stroke")
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
    stroke = node.getAttribute("stroke")
    opacity = @_svgCalcOpacity(node)
    circle = @circle(x, y, r)
    circle.fillColor(fill, opacity).fill() unless fill == "none"
    circle.strokeColor(stroke, opacity).stroke() unless stroke == "none"

  _parsePath: (node) ->
    fill = node.getAttribute("fill")
    stroke = node.getAttribute("stroke")
    lineWidth = parseInt(node.getAttribute("stroke-width"))
    d = node.getAttribute("d")
    opacity = @_svgCalcOpacity(node)

    @lineWidth(lineWidth) if lineWidth
    path = @path(d)
    if fill != "none" and stroke != "none"
      path.fillColor(fill, opacity).
           strokeColor(stroke, opacity).fillAndStroke()
    else
      path.fillColor(fill, opacity).fill() unless fill == "none"
      path.strokeColor(stroke, opacity).stroke() unless stroke == "none"

  _parseText: (node) ->
    x = Math.round(parseFloat(node.getAttribute("x")))
    y = Math.round(parseFloat(node.getAttribute("y")))
    transform = node.getAttribute("transform")
    textContent = node.textContent
    fontSize = window.getComputedStyle(node).getPropertyValue("font-size")
    fontSize = parseInt(fontSize)

    rotate = @_getSvgRotationValues(transform)
    opacity = @_svgCalcOpacity(node)

    @fontSize(fontSize)
    @fillColor("black", opacity)
    @fill
    @rotate(rotate[0], origin: [rotate[1], rotate[2]]) if rotate
    @text(textContent, x, y, width: 100)
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

