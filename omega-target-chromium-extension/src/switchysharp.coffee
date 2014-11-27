OmegaTarget = require('omega-target')
OmegaPac = OmegaTarget.OmegaPac
Promise = OmegaTarget.Promise

module.exports = class SwitchySharp
  extId: 'oheiiidjlelbjilmglommidcfknfidpd'
  port: null

  monitor: (action) ->
    if not port? and not @_monitorTimerId
      @_monitorTimerId = setInterval @_connect.bind(this), 5000
      if action != 'reconnect'
        @_connect()

  getOptions: ->
    if not @_getOptions
      @_getOptions = new Promise (resolve) =>
        @_getOptionsResolver = resolve
        @monitor()
    @_getOptions

  _getOptions: null
  _getOptionsResolver: null
  _monitorTimerId: null

  _onMessage: (msg) ->
    if @_monitorTimerId
      clearInterval @_monitorTimerId
      @_monitorTimerId = null
    if @_getOptionsResolver
      @port.postMessage({action: 'getOptions'})
    switch msg?.action
      when 'state'
        # State changed.
        OmegaTarget.Log.log(msg)
      when 'options'
        @_getOptionsResolver?(msg.options)

  _onDisconnect: (msg) ->
    @port = null
    @_getOptions = null
    @_getOptionsResolver = null
    @monitor('reconnect')

  _connect: ->
    if not @port
      @port = chrome.runtime.connect(@extId)
      @port.onDisconnect.addListener(@_onDisconnect.bind(this))
      @port.onMessage.addListener(@_onMessage.bind(this))
    try
      @port.postMessage({action: 'disable'})
    catch
      @port = null
    return @port?