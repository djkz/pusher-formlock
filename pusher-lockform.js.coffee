# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->
    form_id = $("body").find("form").attr("id")
    if form_id
        form_channel = pusher.subscribe("presence-#{form_id}")
        editor_id = null
        id = null

        form_channel.bind 'pusher:subscription_succeeded', () ->
            id = form_channel.members.me.id

        form_channel.bind "client-start-edit", (data) ->
            editor_id = data.editor_id
            if editor_id != id
                $("##{form_id} input").prop("disabled", true)

        form_channel.bind "client-finish-edit", (data) ->
            editor_id = null
            $("##{form_id} input").prop("disabled", false)

        form_channel.bind "pusher:member_added", (member) ->
            if editor_id == id
                form_channel.trigger "client-start-edit", {editor_id : id}

        form_channel.bind 'pusher:member_removed', (member) ->
            if editor_id == member.id
                editor_id = null
                $("##{form_id} input").prop("disabled", false)

        $( document ).on 'focusin', 'input', () ->
            editor_id = id
            form_channel.trigger "client-start-edit", {editor_id : id}

        $( document ).on 'focusout', 'input', () ->
            editor_id = null
            form_channel.trigger "client-finish-edit", {}


