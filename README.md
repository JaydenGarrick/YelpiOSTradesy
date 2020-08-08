# Jayden Garrick

## Approach
The approach I took was MVP with Protocol Oriented Programming. I tried to separate my dependencies out into interfaces so I can easily mock them out for efficient Unit Testing. 

## Findings / Notes
* One huge road block I ran into was getting CoreLocation working on the simulator... I didn't realize you had to enable custom locations in the simulator, so I was banging at that location stuff for a bit
* Adding call functionality was surprisingly easy, and I thought it'd be a cool idea since the API gives you back a phone number
* YELP Api required a little bit of digging, and I had to dig to understand how the headers work

## If I Had More Time
* I wanted to add unit tests to the networking client + image stuff, unfortunately I ran out of time, and I hope my presenter tests show my unit test competency
* The `BusinessDetailViewController` is kind of gross and you should probably ignore it - haha. I wanted to do a quick little detailVC but I started running out of time so I quickly got something out so at least the app wasn't crashing when you tapped on the cell
> 📝 *Note: I'm not sure why I did it modally - I thought the cross dissolve look would be kind of cool, but it's actually kind of clunky*
* I'd want to fix up the UX a bit - add some kind of loading indicator when the network call begins
