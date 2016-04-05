module.exports = 
  svg: (graph, x, y, options) ->
    width = graph.getAttribute("width")
    height = graph.getAttribute("height")
    return @_parseNode node for node in graph.children

  _parseNode: (node, parent) ->
    switch node.nodeName
      when "svg"
        @_parseNode(node) for node in node.children
      when "g"
        @_parseNode(node) for node in node.children
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

  _parseRect: (node) ->
    width = node.getAttribute("width")
    height = node.getAttribute("height")
    x = node.getAttribute("x")
    y = node.getAttribute("y")
    fill = node.getAttribute("fill")
    stroke = node.getAttribute("stroke")
    rect = @rect(x, y, width, height)
    rect.fill(fill) unless fill == "none"
    rect.stroke(stroke) unless stroke == "none"

  _parseLine: (node) ->
    stroke = node.getAttribute("stroke")
    x1 = node.getAttribute("x1")
    y1 = node.getAttribute("y1")
    x2 = node.getAttribute("x2")
    y2 = node.getAttribute("y2")
    @moveTo(x1, y1).
      lineTo(x2, y2).
      stroke(stroke)

  _parseCircle: (node) ->
    x = Math.round(parseFloat(node.getAttribute("cx")))
    y = Math.round(parseFloat(node.getAttribute("cy")))
    r = parseInt(node.getAttribute("r"))
    fill = node.getAttribute("fill")
    stroke = node.getAttribute("stroke")
    circle = @circle(x, y, r)
    circle.fill(fill) unless fill == "none"
    circle.stroke(stroke) unless stroke == "none"

  _parsePath: (node) ->
    fill = node.getAttribute("fill")
    stroke = node.getAttribute("stroke")
    lineWidth = parseInt(node.getAttribute("stroke-width"))
    d = node.getAttribute("d")

    @lineWidth(lineWidth) if lineWidth
    path = @path(d)
    if fill != "none" and stroke != "none"
      path.fillAndStroke(fill, stroke)
    else
      path.fill(fill) unless fill == "none"
      path.stroke(stroke) unless stroke == "none"

  _parseText: (node) ->
    x = Math.round(parseFloat(node.getAttribute("x")))
    y = Math.round(parseFloat(node.getAttribute("y")))
    transform = node.getAttribute("transform")
    textContent = node.textContent
    fontSize = window.getComputedStyle(node).getPropertyValue("font-size")
    fontSize = parseInt(fontSize)

    rotate = @_getSvgRotationValues(transform)

    @fontSize(fontSize)
    @fill("black")
    @rotate(rotate[0], origin: [rotate[1], rotate[2]]) if rotate
    @text(textContent, x, y, width: 100)
    @rotate(- rotate[0], origin: [rotate[1], rotate[2]]) if rotate

  _getSvgRotationValues: (text) ->
    pattern = /rotate\(\d+,\d+,\d+\)/
    if pattern.test(text)
      rotate = text.match(pattern)[0]
      values = rotate.split("(")[1].split(")")[0].split(",")
      results = (Math.round(parseFloat(value)) for value in values)
    else
      results = undefined
    results

