# ReservableRooms 

#### This addon allows you to create a reservable spot anywhere in the map, if you are able to edit the map and add the entity.

## Features:

Claiming: Claiming a room, will result in you getting that room if there are no players or props that arent yours in the room.
This also automatically adds players on your prop protection buddy list to the allowed players in the room.
Unclaiming completely wipes the allowed players from the room, meaning it is free to claim again, no it does not delete props or anything inside.

Buddies: Claiming a room will give your prop protection buddy list access to the room too, on most servers this means admins as well.

Door locking: Doors automatically close and lock upon claiming the room with the door, doors unlock upon user confirmation or unclaiming/leaving.

###### Bugs will be fixed if reported, in a time frame at least.

###### Do not claim this addon as yours.

###### Because of the way this addon works, ANY change in ANY character of the lua files will require a map change or restart.

## Chat commands:

!claim ID ( Claims the requested spot if everything is a-ok )

!clear ID ( Clears the allowed player list for that spot ( Admin+ only command ))

!lockdoor ( Locks your door if you have a reserved room )

( removed )!refreshfriends ( Rechecks your friends list ( Prop protection buddy list ) and adds or removes them to your spot if you own one. )

!rrv ( Returns server version of ReservableRooms )

!unclaim ( Unclaims a spot if you own it ( Does not require ID ))

!unlockdoor ( Unlocks your door if you have a reserved room )

## F.A.Q.

> Does this support buddy lists?

Yes.

> Will a 500 prop car being removed lag the server?

Depends on the server.
 
> What do I need to use this addon?

A CPPI complient prop protection, and a map with the entities.

> Who made this addon?

I (Bkamahl/BabyBear) single handedly coded this addon with the help of the Gmod Wiki and some Facepunch threads.

> Why did you make this?

So people on advanced building servers can't be annoyed while building, if they wanted. 

> Where do I report bugs?

Either make an issue on GitHub or contact me on Steam(id/Bkamahl) or Discord(BabyBear#5785).

>What is the hammer entity called?

"reservableroom"

## Instructions:

In hammer, on your map, create a block with the tools/toolstrigger texture

While the block is selected use Ctrl + T to create an entity

Turn smart edit off and when selecting the entity class, clear and type reservableroom

Then create a key called "RID" ( All caps ), then give it a value between 1 (one) through whatever number you want

## Config:

Most of the config is in the server file, pretty obv too, uh to change the client feedback color
open the cl_reservablerooms.lua file, pretty self explanitory.

## Changelog

V1: First addon release

V2: Added fancy feedback, and optimized PlayerSay hook and entire system with a table.

V3: Removed useless args from whatsinthebox function, made feedback for !refreshfriends more straight forward, removed useless "worldspawn" from ignoredprops, and shortened/optimized entire code by remove entire "ranfromclaimed" system that was replaced with if ent != nil that did not work before as of other bugs that were fixed before addon release.

V4: Made sure entering letters or incorrect ID numbers don't cause errors and have feedback alerting user if it's incorrect.

V5: Fixed not being able to claim room while being inside of room, even if your friend is in the room, alphabetically ordered hooks, and added auto friend refresh for every room owner if there is an owner, default is 2 minutes, variable is changable.

V6: Changed default refresh timer to 2.5 for MG, removed some useless brackets in some if statements, and completely fixed autoRefresh and made it's own function for it.

V7: Removed some useless brackets, and removed a couple lines that could possibly cause some rare problems.

V8: Replaced a couple if statements with one optimizing the check if player asking to claim is in the room hopefully fixing weird error on some servers that does not allow players to claim a room while in it.

V9: Added ent from face poser tool to ignored list as it blocked players from claiming room while inside of it.

V10: Added if not nil to start touch so that PA mirror's work and may solve issues with other addons too.

V11: Merge from WizardLizard to silently kill players instead of normally killing them leading to ragdoll and death sound.

V12: Made hook names more unique to make conflict with other addons more rare, you can now only claim a room if it is empty, you are in it, or if there are props in it and they are yours.

V13: Made ReservableRooms ignore world or null owner props, added !rrv to retrieve the servers ReservableRooms version, and changed order of which ReservableRooms entity handles props.

V14: Added door locking! Door automatically locks when you claim a room, use "!unlockdoor" to unlock your door and "!lockdoor" to lock your door.

V15: Organized variables in server file for a more friendly user configuration, added doorEnable variable to toggle door system, removed door close on unclaim/unlocking of door, removed useless spaces, fixed conflict between chat and door system, completely removed ignoredprops system as code ignores nill or world props and why do you want to ignore a certain players certain prop?, removed useless otherFunctionsAreRunning on some functions as it could cause errors with timer fail safe, and added message to client if they enter an unclaimed room to claim it using entity netvar and server setnetvar. Allot can be optimized currently, with what I have recently found out, but I will save that for a later update.

V16: Complete recode, friends system is pretty much auto, you dont have to do anything except set your friends in your prop protection, itl work, uhhh, things are more optimized, dropped like 100 lines of code.

V17: Fixed some dumb things with some servers by setting a timer higher.

V18: Remove useless arguement in checkRoomOwnerShip function, changed some variables to be more easily recognizable, and changed reserve notification to tell you how to interact with the door.

V19: Updated !claim feedback to tell you the door is already locked