# esx_property_rework
A rework of esx property done by ElPumpo and combined it with a garage script from TanguyOrtegat. All I did was ehance certain things and edit others. So obviously, I have not created any of this and all credit to that should go to ElPump and TanguyOrtegat... and who ever else was responsible for those scripts.

I have been trying to get a rework of esx_property without the instance and was able to modify the script that took out all instancing from esx_property. With that being said, there are a few things to note.

1) There is no going inside houses to get to the property rooms for property stored inventory. You will have to edit and reconfigure the property rooms yourself. A knowledge of SQL is all you need in order to do this for the DB. Otherwise, its pretty straight forward stuff.

2) I will be editing things as I go and will update the properties as best as I can. However, I am a single dev for my whole community and work a lot. So the chances of me fixing something right away will most likely not happen. With that also being said, I cannot fully support the build for people and anyone who is doing any customizing on the script is on their own. Sorry, but I just don't really have the time.

3) Garages used by this script are separate from public garages. Certain properties will have garages while others don't. I configured it to my server but obviously we don't all have the same points for things.

4) I can't say whether or not this script will work with a real estate agent.... So GLHF if you do that.

Here are some enhancements that I have done with the script.

1) Garage system is now part of the script and works for owned homes.

2) Every IRL minute, the script will query the DB to see if ANY new places were purchased. If they were, it will update it.

3) When selling a home, IF IT WAS BOUGHT then the seller has a chance to earn anywhere between half of what the property sells for UP TO 1.5 times the amount and it goes directly into their bank account. If its rented, they don't get anything.

4) Removed Blips.... cause I hate blips.

5) If you sell a property, it immediately becomes up for sale.

There will be more added later, but I am tired and want to get this posted. Thanks for trying it out and let me know if you like it or not.
