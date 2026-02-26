extends Node

signal on_client_wait_timeout(queue_index)
signal on_client_selected(client)
signal on_document_stamped(document)
signal on_document_submitted_correct(client, document)
signal on_document_submitted_wrong(client, document, reason)

# Audio signals
signal sfx_click
signal sfx_drag_start
signal sfx_drag_end
signal sfx_drop_success
signal sfx_drop_fail
signal sfx_popup_open
signal sfx_popup_close
signal sfx_hover
signal sfx_stamp
signal sfx_ink
