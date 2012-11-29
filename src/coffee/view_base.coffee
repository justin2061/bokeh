# module setup stuff
if this.Continuum
  Continuum = this.Continuum
else
  Continuum = {}
  this.Continuum = Continuum


build_views = (mainmodel, view_storage, view_specs, options, view_options) ->
  # ## function : build_views
  # convenience function for creating a bunch of views from a spec
  # and storing them in a dictionary keyed off of model id.
  # views are automatically passed the model that they represent

  # ####Parameters
  # * mainmodel : model which is constructing the views, this is used to resolve
  #   specs into other model objects
  # * view_storage : where you want the new views stored.  this is a dictionary
  #   views will be keyed by the id of the underlying model
  # * view_specs : list of view specs.  view specs are continuum references, with
  #   a typename and an id.  you can also pass options you want to feed into
  #   the views constructor here, as an 'options' field in the dict
  # * options : any additional option to be used in the construction of views
  # * view_option : array, optional view specific options passed in to the construction of the view
  "use strict";
  created_views = []
  valid_viewmodels = {}
  for spec in view_specs
    valid_viewmodels[spec.id] = true
  for spec, idx in view_specs
    if view_storage[spec.id]
      continue
    model = mainmodel.resolve_ref(spec)
    if view_options
      view_specific_option = view_options[idx]
    else
      view_specific_option = {}
    temp = _.extend({}, view_specific_option, spec.options, options, {'model' : model})
    try
      view_storage[model.id] = new model.default_view(temp)
    catch error
      #console.log("error on temp of", temp, "model of", model, error)
      console.log("error on model of", model, error)
      throw error
    created_views.push(view_storage[model.id])
  for own key, value of view_storage
    if not valid_viewmodels[key]
      value.remove()
      delete view_storage[key]
  return created_views

Continuum.build_views = build_views

class ContinuumView extends Backbone.View
  initialize : (options) ->
    #autogenerates id
    if not _.has(options, 'id')
      this.id = _.uniqueId('ContinuumView')
  remove : ->
    #handles lifecycle of events bound by safebind

    if _.has(this, 'eventers')
      for own target, val of @eventers
        val.off(null, null, this)
    @trigger('remove')
    super()

  mget : ()->
    # convenience function, calls get on the associated model

    return @model.get.apply(@model, arguments)

  mset : ()->
    # convenience function, calls set on the associated model

    return @model.set.apply(@model, arguments)

  mget_ref : (fld) ->
    # convenience function, calls get_ref on the associated model

    return @model.get_ref(fld)

Continuum.ContinuumView = ContinuumView