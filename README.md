# Mobile Dev Final Project

## Group Members
Keiran MacKay - 100747838

Naveenan Vigitharan - 100867059

Justin Lau - 100877853

Ata-US-Samad Khan - 100754092

WalletFlow, a banking app that can be shared by multiple people to track expenses.

## Pages
### Log In
Takes a username and password as inputs. 
### Account Creation
Takes an Email, Username, Password, and the names of 2-6 people (a button is provided to add people) then returns to the Log in page while showing a snackbar which tells the user their account was created successfully.
### Home Page
The home page contains a bar graph showing the monthly spending of each user. Below is the total spending of each person in the current month, this can be scrolled left and right if there are more than two people. Finally at the bottom, a transaction history is given. 
Each transaction contains the persons name, place, date, and amount spent. If you click on a transaction it will change to a bill info page.
### Monthly Breakdown
The monthly breakdown page contains a pie chart which shows the total spending of each person. The pie chart can be scrolled left and right to change the month which is being viewed. Only months with a transaction history are available.
Below is the names and total spent of each person in that selected month, also scrollable if there are more than two people. A full in depth transaction history is below.
### Bill Info
The bill info page contains all of the in depth information of that transaction. This includes Name, Location, Date, Price, if the bill is reoccuring, notes (optional), and finally a photo (optional)
### Add Bill
The add bill page is where transactions are logged. The user must choose a name, input the place, date, price, reoccuring, notes (optional), photo (optional).
When the submit button is pressed the transaction will be saved to the database and the homepage and monthly breakdown page will be updated
### Profile
The profile page contains the Username of the account plus every member's name and a profile icon. At the bottom is a button which is used for logging out
