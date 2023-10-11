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
    
    @db = CallDatabse.new
    @db.initDB

    # functions for displaying options and getting user input

    def getBackOrExitOption(option, onBack)
        print "\n#{option} (B/X): "
        option = gets.chomp.downcase

        if option == "b"
            onBack.call
        elsif option == "e"
            system('exit')
        else
            puts "Enter a valid option"
            getBackOrExitOption(option)
        end
    end

    def getRetryHomeOrExitOption(message, onRetry, onHome)
        print "\n#{message} (R/H/X): "
        option = gets.chomp.downcase

        if option == "r"
            onRetry.call
        elsif option == "h"
            onHome.call
        elsif option == "x"
            system('exit')
        else
            puts "Enter a valid option"
            getRetryHomeOrExitOption(message, onRetry, onHome)
        end
    end

    def getChooseMenuOption(message)
        print "\n#{message}: "
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
            getChooseMenuOption(message)
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
        puts "*******Address Book*******"
        puts "\Select an option"

        puts "\n1. Add contact"
        puts "2. Edit contact"
        puts "3. Delete contact"
        puts "4. View all contacts"

        puts "\n0. Exit"

        getChooseMenuOption("Choose an option(0-4)")
    end

    # Operations for the menu options(Add, Edit, Delete, View)

    def getContactDetails(label, detail)
        print "\nEnter #{label}: "
        detail = gets.chomp
        while detail == ""
            puts "#{label} is required"
            print "\nEnter #{label}: "
            detail = gets.chomp
        end

        return detail
    end

    def displayContacts(contacts)
        if contacts.ntuples == 0
            puts "No contacts found"
            getBackOrExitOption("Press (B or X) to go back or exit", 
                -> { main }
            )
        
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
            -> { getRetryHomeOrExitOption("Press (H, R, X) to retry entry, go home, or exit.", 
                -> {addContact}, 
                -> {main}
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
                -> { getRetryHomeOrExitOption("Press (H, R, X) to retry entry, go home, or exit.", 
                    -> {editContact}, 
                    -> { main }
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

        # display all contacts first
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
                -> { getRetryHomeOrExitOption("Press (H, R, X) to retry entry, go home, or exit.", 
                    -> {deleteContact}, 
                    -> { main }
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
        
        getBackOrExitOption("Press B to go back and X to exit", 
            -> { main }
        )
    end

    # Database operations

    def addContactToDB(firstName, lastName, phoneNumber, region, suburb)

        @db.getDB.exec("INSERT INTO contacts (first_name, last_name, phone_number, region, suburb) VALUES ('#{firstName}', '#{lastName}', '#{phoneNumber}', '#{region}', '#{suburb}')")
    
        puts "Contact added successfully"

        getBackOrExitOption("Press (B or X) to go back or exit", 
            -> { main }
        )
    end

    def getNewDetail(detail, newDetail, label)
        print "Enter new #{label}(#{detail}): "
        newDetail = gets.chomp
        while newDetail == ""
            print "Do you want to keep #{label} as #{detail}? (y/n): "
            option = gets.chomp.downcase

            if option == "y"
                newDetail = detail
            elsif option == "n"
                print "Enter new #{label}: "
                newDetail = gets.chomp
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
        region = ''
        suburb = ''


        getNewDetail(firstName, newFirstName, "first name")
        getNewDetail(lastName, newLastName, "last name")
        getNewDetail(phoneNumber, newPhoneNumber, "phone number")
        getNewDetail(region, newRegion, "region")
        getNewDetail(suburb, newSuburb, "suburb")

        @db.getDB.exec("UPDATE contacts SET first_name = '#{newFirstName}', last_name = '#{newLastName}', phone_number = '#{newPhoneNumber}', region = '#{newRegion}', suburb = '#{newSuburb}' WHERE id = '#{contact['id']}'")

        # puts contact['id'].inspect

        puts "\nContact Edited successfully"

        getBackOrExitOption("Press (B or X) to go back or exit", 
            -> { main }
        )
    end

    def deleteContactInDB(index, contact)
            
        @db.getDB.exec("DELETE FROM contacts WHERE id = '#{contact['id']}'")

        puts "\nContact deleted successfully"
    
        getBackOrExitOption("Press (B or X) to go back or exit", 
            -> { main }
        )
    end


end

include AddressBook

AddressBook::main