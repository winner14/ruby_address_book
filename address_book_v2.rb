require 'pg'

module AddressBook
    class CallDatabse
        def initialize
            @db = initDB
            @contacts = []
        end
    
        def initDB
            PG.connect( dbname: 'address_book', host: 'localhost', port: '5432', user: 'postgres', password: 'zero2four' )
        end
    
        def getDB
            @db
        end
    end

    # functions for displaying options and getting user input

    def getBackOrExitOption()
        puts "\nChoose an option"
        puts "1. Home"
        puts "0. Exit"
        option = gets.chomp

        if option == "1"
            main()
        elsif option == "0"
            system('exit')
        else
            puts "Enter a valid option"
            getBackOrExitOption()
        end
    end

    def getRetryHomeOrExitOption(onRetry)
        puts "\nChoose an option"
        puts "1. Retry"
        puts "2. Home"
        puts "0. Exit"

        option = gets.chomp

        if option == "1"
            onRetry.call
        elsif option == "2"
            main()
        elsif option == "0"
            system('exit')
        else
            puts "Enter a valid option"
            getRetryHomeOrExitOption(onRetry)
        end
    end

    def getChooseMenuOption()
        print "Choose an option(0-4): "
        option = gets.chomp

        if option == "0" || option == "1" || option == "2" || option == "3" || option == "4"
            case option
            when '0'
                system('exit')
            when '1'
                addContact()
            when '2'
                editContact()
            when '3'
                deleteContact()
            when '4'
                viewContacts()
            end
        else
            puts "\Enter a valid option"
            getChooseMenuOption()
        end
    end

    def getYesOrNoOption(message, onYes, onNo)
        print "\n#{message} (y/n): "
        option = gets.chomp.downcase

        if option == "y"
            onYes.call
        elsif option == "n"
            onNo.call
        else
            puts "Enter a valid option"
            getYesOrNoOption(message, onYes, onNo)
        end
    end

    # The main menu
    
    def main
        system('clear')
        puts "*******Address Book*******"
        puts "\Select an option"

        puts "\n1. Add contact"
        puts "2. Edit contact"
        puts "3. Delete contact"
        puts "4. View all contacts"

        puts "\n0. Exit"

        getChooseMenuOption()
    end

    # Operations for the menu options(Add, Edit, Delete, View)

    def getContactDetails(label, detail)
        print "\nEnter #{label}: "
        detail = gets.chomp.capitalize
        while detail == ""
            puts "#{label} is required"
            print "\nEnter #{label}: "
            detail = gets.chomp.capitalize
        end

        return detail
    end

    def displayContacts(contacts)
        if contacts.ntuples == 0
            puts "No contacts found"
            getBackOrExitOption()
        
        else
            contacts.each.with_index(1) do |contact, index|
                puts "\n#{index}-----------------------"
                puts "First name: #{contact['first_name']}"
                puts "Last name: #{contact['last_name']}"
                puts "Phone number: #{['phone_number']}"
                puts "Region: #{contact['region']}"
                puts "Suburb: #{contact['suburb']}"
            end
        end
    end

    def displaySelectedContact(firstName, lastName, phoneNumber, region, suburb)
        puts "\nFirst name: #{firstName}"
        puts "Last name: #{lastName}"
        puts "Phone number: #{phoneNumber}"
        puts "Region: #{region}"
        puts "Suburb: #{suburb}"
    end

    def addContact
        puts "********Add Contact********"

        firstName =  getContactDetails("first name", firstName)
        lastName = getContactDetails("last name", lastName)
        phoneNumber = getContactDetails("phone number", phoneNumber)    
        region = getContactDetails("region", region)
        suburb = getContactDetails("suburb", suburb)

        displaySelectedContact(firstName, lastName, phoneNumber, region, suburb)

        getYesOrNoOption("Do you want to add contact with the above details?",
            -> { addContactToDB(firstName, lastName, phoneNumber, region, suburb) },
            -> { getRetryHomeOrExitOption(
                    -> {addContact},
                ) 
            }
        )          

    end

    def editContact
        puts "********Edit Contact********"

        contacts = @db.getDB.exec("SELECT * FROM contacts")

        displayContacts(contacts)

        print "\nEnter the number of the contact you want to edit or (b) to go back: "
        option = gets.chomp

        if option.downcase == "b"
            main
        elsif option.to_i > 0 && option.to_i <= contacts.ntuples
            contact = contacts[option.to_i - 1]

            displaySelectedContact(contact['first_name'], contact['last_name'], contact['phone_number'], contact['region'], contact['suburb'])
            
            getYesOrNoOption("Do you want to edit this contact?", 
                -> {editContactInDB(option.to_i-1, contact)}, 
                -> { getRetryHomeOrExitOption(
                    -> {editContact}
                    )
                }
            )
        else
            puts "Enter a valid option"
            editContact
        end
    end

    def deleteContact
        puts "********Delete Contact********"

        contacts = @db.getDB.exec("SELECT * FROM contacts")

        displayContacts(contacts)

        print "\nEnter the number of the contact you want to delete or (b) to go back: "
        option = gets.chomp

        if option.downcase == "b"
            main
        elsif option.to_i > 0 && option.to_i <= contacts.ntuples
            contact = contacts[option.to_i - 1]

            displaySelectedContact(contact['first_name'], contact['last_name'], contact['phone_number'], contact['region'], contact['suburb'])

            getYesOrNoOption("Do you want to delete this contact?", -> {deleteContactInDB(option.to_i-1, contact)}, 
                -> { getRetryHomeOrExitOption(
                    -> {deleteContact}
                    )
                }
            )
        else
            puts "Enter a valid option"
            deleteContact
        end

    end

    def viewContacts
        puts "********View Contacts********"

        contacts = @db.getDB.exec("SELECT * FROM contacts")

        displayContacts(contacts)
        
        getBackOrExitOption()
    end

    # Database operations

    
    

    def addContactToDB(firstName, lastName, phoneNumber, region, suburb)

        @db.getDB.exec("INSERT INTO contacts (first_name, last_name, phone_number, region, suburb) VALUES ('#{firstName}', '#{lastName}', '#{phoneNumber}', '#{region}', '#{suburb}')")
    
        puts "Contact added successfully"

        getBackOrExitOption()
    end

    def getNewDetail(detail, newDetail, label)
        print "Enter new #{label}(#{detail}): "
        newDetail = gets.chomp.capitalize
        while newDetail == ""
            print "Do you want to keep #{label} as #{detail}? (y/n): "
            option = gets.chomp.downcase

            if option == "y"
                newDetail = detail
            elsif option == "n"
                print "Enter new #{label}: "
                newDetail = gets.chomp.capitalize
            else
                puts "Enter a valid option"
                getNewDetail(detail, newDetail, label)
            end
        end
    end

    def editContactInDB(index, contact)
        firstName = contact['first_name']
        lastName = contact['last_name']
        phoneNumber = contact['phone_number']
        region = contact['region']
        suburb = contact['suburb']
        newFirstName = ''
        newLastName = ''
        newPhoneNumber = ''
        newRegion = ''
        newSuburb = ''


        getNewDetail(firstName, newFirstName, "first name")
        getNewDetail(lastName, newLastName, "last name")
        getNewDetail(phoneNumber, newPhoneNumber, "phone number")
        getNewDetail(region, newRegion, "region")
        getNewDetail(suburb, newSuburb, "suburb")

        @db.getDB.exec("UPDATE contacts SET first_name = '#{newFirstName}', last_name = '#{newLastName}', phone_number = '#{newPhoneNumber}', region = '#{newRegion}', suburb = '#{newSuburb}' WHERE id = '#{contact['id']}'")

        puts "\nContact Edited successfully"

        getBackOrExitOption()
    end

    def deleteContactInDB(index, contact)
            
        @db.getDB.exec("DELETE FROM contacts WHERE id = '#{contact['id']}'")

        puts "\nContact deleted successfully"
    
        getBackOrExitOption()
    end


end

include AddressBook

AddressBook::main