extends Node

#Item data format: [0: ID, 1: name, 2: max stack, 3: type[EX: material, weapon, tool], 4: description, 5: class, 6: durability, 7: more info(how to get it)]
#Note: description, class, and durability sections only have to be filled out for non-materials Eg. tools, weapons, consumables
#Format for "more info" section:
#For any material that is dropped from a block write Obtained from...
#For any material that is dropped from an enemy write Drops from...
#For any material that is crafted write crafted in/on...
#Note: if a material has more than one way to obtain it just write the most common way to obtain it
const ITEM_DATA = [
	[0,"empty",0,"material","","",0,""],
	[0,"stone",9999,"material","","",0,"Obtained from rocks in cave layer."],
	[0,"crude iron cluster",9999,"material","","",0,"Obtained from ore clusters in cave layer."],
	[0,"iron ingot",9999,"material","","",0,"Crafted in furnace."],
	[0,"plant fiber",9999,"material","","",0,"Obtained from lichen mats in cave layer."],
	]

const CHUNK_SIZE := 32
