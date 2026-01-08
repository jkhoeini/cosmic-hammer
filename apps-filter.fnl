
(local apps-filter (hs.window.filter.new))

(filter:setAppFilter :Emacs {:allowRoles [:AXUnknown :AXStandardWindow :AXDialog :AXSystemDialog]})

{: apps-filter}
