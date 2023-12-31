# require 'pg'

module AddressBook
    class Contact
        attr_accessor :firstName, :lastName, :phoneNumber, :region, :suburb

        def initialize(firstName, lastName, phoneNumber, region, suburb)
            @firstName = firstName
            @lastName = lastName
            @phoneNumber = phoneNumber
            @region = region
            @suburb = suburb
        end
        
    end

    class CallFile
        def initialize
            @file = initFile
            # @contacts = []
        end
    
        def initFile
            if !File.exist?('contacts.txt')
                File.open('contacts.txt', 'w'){}
            end
        end
    
        def getFile
            @file
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

    def validateNumber(phoneNumber)
        /^(233|0)[0-9]{9}$/ === phoneNumber
    end

    def getPhoneNumber()
        print "\nEnter phone number: "
        phoneNumber = gets.chomp
        while phoneNumber == "" || !validateNumber(phoneNumber) 
            puts "Enter Valid phone number"
            print "\nEnter phone number: "
            phoneNumber = gets.chomp
            if validateNumber(phoneNumber) == true
                break
            end
        end

        return phoneNumber
    end

    def getNewPhoneNumber(phoneNumber)
        # pn = phoneNumber
        print "Enter new phone number(#{phoneNumber}): "
        newPhoneNumber = gets.chomp
        while newPhoneNumber == "" || !validateNumber(newPhoneNumber)
            print "Enter Valid phone number: "
            newPhoneNumber = gets.chomp
            if validateNumber(newPhoneNumber) == true
                break
            end
        end

        return newPhoneNumber
    end

    def displayContacts
        if @contacts.length == 0
            puts "No contacts found"
            getBackOrExitOption()
        
        else
            @contacts.each.with_index(1) do |contact, index|
                puts "\n#{index}. #{contact.firstName} #{contact.lastName} - #{contact.phoneNumber}"
            end
        end
    end

    def displaySelectedContact(contact)
        puts "#{contact.firstName} #{contact.lastName} - #{contact.phoneNumber}"
    end

    def addContact
        puts "********Add Contact********"

        firstName =  getContactDetails("first name", firstName)
        lastName = getContactDetails("last name", lastName)
        phoneNumber = getPhoneNumber()    
        region = getContactDetails("region", region)
        suburb = getContactDetails("suburb", suburb)

        displaySelectedContact(Contact.new(firstName, lastName, phoneNumber, region, suburb))

        getYesOrNoOption("Do you want to add contact with the above details?",
            -> { addContactToFile(Contact.new(firstName, lastName,phoneNumber, region,suburb)) },
            -> { getRetryHomeOrExitOption(
                    -> { addContact },
                ) 
            }
        )          

    end

    def loadContacts
        @contacts = []
        File.open('contacts.txt', 'r') do |file|
            file.each_line do |line|
              f, l, p, r, s = line.chomp.split(',')
              contact = Contact.new(f, l, p, r, s)
              @contacts.push(contact)
            end
        end
    end

    def editContact
        puts "********Edit Contact********"

        loadContacts()

        displayContacts()

        print "\nEnter the number of the contact you want to edit or (b) to go back: "
        option = gets.chomp

        if option.downcase == "b"
            main
        elsif option.to_i > 0 && option.to_i <= @contacts.length
            contact = @contacts[option.to_i - 1]

            displaySelectedContact(contact)
            
            getYesOrNoOption("Do you want to edit this contact?", 
                -> {editContactInFile(option.to_i-1, contact)}, 
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

        loadContacts()

        displayContacts

        print "\nEnter the number of the contact you want to delete or (b) to go back: "
        option = gets.chomp

        if option.downcase == "b"
            main
        elsif option.to_i > 0 && option.to_i <= @contacts.length
            contact = @contacts[option.to_i - 1]

            displaySelectedContact(contact)

            getYesOrNoOption("Do you want to delete this contact?", -> {deleteContactInFile(option.to_i-1)}, 
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

        loadContacts()

        displayContacts
        
        getBackOrExitOption()
    end

    # Database operations

    def addContactToFile(contact)
        
        File.open('contacts.txt', 'a') do |file|
            
            file.puts ("#{contact.firstName},#{contact.lastName},#{contact.phoneNumber},#{contact.region},#{contact.suburb}")
            
        end      

        
        puts "Contact added successfully"

        getBackOrExitOption()
    end

    def getNewDetail(detail, label)
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

        newDetail
    end

    def editContactInFile(index, contact)

        newFirstName = getNewDetail(contact.firstName, "first name")
        newLastName = getNewDetail(contact.lastName, "last name")
        newPhoneNumber = getNewPhoneNumber(contact.phoneNumber)
        newRegion = getNewDetail(contact.region, "region")
        newSuburb = getNewDetail(contact.suburb, "suburb")


        puts "#{newFirstName},#{newLastName},#{newPhoneNumber},#{newRegion},#{newSuburb}}"

        @contacts[index] = Contact.new(newFirstName, newLastName, newPhoneNumber, newRegion, newSuburb)

        File.open('contacts.txt', 'w') do |file|
                @contacts.each do |contact|
                file.puts ("#{contact.firstName},#{contact.lastName},#{contact.phoneNumber},#{contact.region},#{contact.suburb}")
                end
         end 

        puts "\nContact Edited successfully"

        getBackOrExitOption()
    end

    def deleteContactInFile(index)
        @contacts.delete_at(index)

        File.open('contacts.txt', 'w') do |file|
            @contacts.each do |contact|
            file.puts ("#{contact.firstName},#{contact.lastName},#{contact.phoneNumber},#{contact.region},#{contact.suburb}")
            end
        end 

        puts "\nContact deleted successfully"
    
        getBackOrExitOption()
    end


end

include AddressBook

AddressBook::main