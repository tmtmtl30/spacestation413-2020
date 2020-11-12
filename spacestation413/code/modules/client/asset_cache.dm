// another proc pseudo-override. woohoo
/datum/asset/spritesheet/chat/register()
	InsertAll("emoji", 'spacestation413/icons/emoji.dmi')
	. = ..()
