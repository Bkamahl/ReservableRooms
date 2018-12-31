ReservableRooms allows you to create a reservable spot anywhere in the map, if you are able to edit the map and add the entity.

Bugs will be fixed if reported, in a time frame at least.

To change the "[ReservableRooms]" color, find the Color() at lines 10 for the server file and 7 for the entity file.

Chat commands:

!claim ID ( Claims the requested spot if everything is a-ok )

!unclaim ( Unclaims a spot if you own it ( Does not require ID ))

!clear ID ( Clears the allowed player list for that spot ( Admin+ only command ))

!refreshfriends ( Rechecks your friends list ( Prop protection buddy list ) and adds or removes them to your spot if you own one. )

Do not claim this addon as yours.

F.A.Q.

Q: Does this support buddy lists? A: Yes.

Q: Will a 500 prop car being removed lag the server? A: Depends on the server.
 
Q: What do I need to use this addon? A: A CPPI complient prop protection, and a map with the entities.

Q: Who all made this addon? A: I (Bkamahl/BabyBear) single handedly coded this addon with the help of the Gmod Wiki and some 
Facepunch threads.

Q: Why did you make this? A: So people on advanced building servers can't be annoyed while building, if they wanted. 

Q: Where do I report bugs? A: Either make an issue on GitHub or contact me on Steam(id/Bkamahl) or Discord(BabyBear#5785).

Q: What is the entity called? A: "reservableroom".

Instructions:

In hammer, on your map, create a block with the tools/toolstrigger texture

While the block is selected use Ctrl + T to create an entity

Turn smart edit off and when selecting the entity class, clear and type reservableroom

Then create a key called "RID" ( All caps ), then give it a value between 1 (one) through whatever number you want

V1: First addon release

V2: Added fancy feedback, and optimized PlayerSay hook and entire system with a table.

V3: Removed useless args from whatsinthebox function, made feedback for !refreshfriends more straight forward, removed useless "worldspawn" from ignoredprops, and shortened/optimized entire code by remove entire "ranfromclaimed" system that was replaced with if ent != nil that did not work before as of other bugs that were fixed before addon release.

V4: Made sure entering letters or incorrect ID numbers don't cause errors and have feedback alerting user if it's incorrect.

V5: Fixed not being able to claim room while being inside of room, even if your friend is in the room, alphabetically ordered hooks, and added auto friend refresh for every room owner if there is an owner, default is 2 minutes, variable is changable.

V6: Changed default refresh timer to 2.5 for MG, removed some useless brackets in some if statements, and completely fixed autoRefresh and made it's own function for it.

V7: Removed some useless brackets, and removed a couple lines that could possibly cause some rare problems.

V8 plans are to check if player has not been in the room for a certain amount of time, and if not to unclaim that room.