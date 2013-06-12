$(document).ready ->
  window.openDonationLine = []
  $("#namesearch")
    .autocomplete( source: (request, response) ->
      $.getJSON '/pledgers/search.json', {name: request.term}, (results) ->
        names = []
        for result in results
          names.push
            id: result.id
            value: result.name
            desc: result.perm_address
        response names # Callback an array of values.
        return false
    select: (event, ui) ->
      window.location = "/pledgers/#{ui.item.id}"
    )
    .data("ui-autocomplete")._renderItem = (ul,item) ->
      $("<li>")
        .append("<a style=\"line-height:1.3\">#{item.value}<br /><span style=\"font-size: 11px; margin-left: 1em;\">#{item.desc}</span></a>")
        .appendTo(ul)

  $(document).on("click",".clickable.donationLine", ->
    window.openDonationLine[$(this).attr('data-id')] = $(this)
    $(this).replaceWith($('<div class="donationForm donationLine">').load("/donations/#{$(this).attr('data-id')}/edit"))
  )

  $(document).on("click","#donationFormCancelButton", ->
    donationID = $(this).attr("data-id")
    $(this).parents(".donationForm").replaceWith(window.openDonationLine[donationID])
    window.openDonationLine[donationID]
  )
