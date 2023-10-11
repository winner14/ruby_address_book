require 'pg'

class Home

    def initialize
        @db = initDB

        puts " in init #{@db}"
        @contacts = []
    end

    def initDB
        PG.connect(dbname: 'address_book', host: 'localhost', port:'5432', user: 'postgres', password: 'zero2four')

    end

    def getDB
        @db
    end

    def home
        system("clear")

        puts "**********Welcome to Winner's Address Book**********"

        puts "\n1. Add new contact"
        puts "2. Edit contact"
        puts "3. View contacts"
        puts "4. Delete contact"

        print "\nEnter (1-4) to select an option or (X) to cancel: "
        option = gets.chomp

        case option
        when '1'
            AddContact.new.addContact
        when '2'
            EditContact.new.editContact
        when '3'
            ViewContacts.new.viewContacts
        when '4'
            DeleteContact.new.deleteContact
        when 'X', 'x'
            system('clear')
        else
            Home.new.home
        end
    end
end

class AddContact
    def addContact
        system('clear')
        puts "**********Add new Contact**********\n"
        print 'Enter first name: '
        firstName = gets.chomp
        while firstName == ''
            puts 'First name cannot be empty'
            print 'Enter first name: '
            firstName = gets.chomp
        end
        print 'Enter last name: '
        lastName = gets.chomp
        while lastName == ''
            puts 'Last name cannot be empty'
            print 'Enter last name: '
            lastName = gets.chomp
        end
        print 'Enter phone number: '
        phoneNumber = gets.chomp
        while phoneNumber == ''
            puts 'Phone number cannot be empty'
            print 'Enter phone number: '
            phoneNumber = gets.chomp
        end
        print 'Enter region: '
        region = gets.chomp
        while region == ''
            puts 'Region cannot be empty'
            print 'Enter region: '
            region = gets.chomp
        end
        print 'Enter suburb: '
        suburb = gets.chomp
        while suburb == ''
            puts 'Suburb cannot be empty'
            print 'Enter suburb: '
            suburb = gets.chomp
        end

        puts "\n You have entered the following details:"
        puts "First name: #{firstName}"
        puts "Last name: #{lastName}"
        puts "Phone number: #{phoneNumber}"
        puts "Region: #{region}"
        puts "Suburb: #{suburb}"

        print 'Press Y to save or any other key to cancel: '
        option = gets.chomp

        if option == 'Y' || option == 'y'
            # contacts = File.new('contacts.txt', 'a+')
            # contacts.puts "#{firstName.capitalize},#{lastName.capitalize},#{phoneNumber},#{region.capitalize},#{suburb.capitalize}\n"

            conxn = Home.new
       
            
            conxn.getDB.exec("INSERT INTO contacts (first_name, last_name, phone_number, region, suburb) VALUES ('#{firstName.capitalize}', '#{lastName.capitalize}', '#{phoneNumber}', '#{region.capitalize}', '#{suburb.capitalize}')")
            
            # contacts.close
            puts "\nContact saved successfully"

            print 'Press any key to go back to home or (X) to exit: '
            _option = gets.chomp
            if _option == 'X' || _option == 'x'
                system('exit')
            else
                Home.new.home
            end
        else
            Home.new.home
        end
    end
end

class EditContact
    def editContact
      system('clear')
      puts "**********Edit Contact**********\n"
  
    #   contacts = File.readlines('contacts.txt')
        
        conxn = Home.new
        contacts = conxn.getDB.exec("SELECT * FROM contacts");

        if contacts.ntuples == 0
            puts "\nNo contacts found"
        else
            contacts.each_with_index do |contact, index|
                # puts "contact  #{contact.inspect}"
            
            puts "\n#{index+1}-------------------------------"
            puts "First name: #{contact['first_name']}"
            puts "Last name: #{contact['last_name']}"
            puts "Phone number: #{contact['phone_number']}"
            puts "Region: #{contact['region']}"
            puts "Suburb: #{contact['suburb']}\n"
            end
        end        

      i = 1
  
    #   if contacts.empty?
    #     puts "\nNo contacts to edit"
    #   else
    #     contacts.each_with_index do |contact, index|
    #       contactData = contact.chomp.split(',')
    #       puts "\n#{i}-------------------------------"
    #       puts "First name: #{contactData[0]}"
    #       puts "Last name: #{contactData[1]}"
    #       puts "Phone number: #{contactData[2]}"
    #       puts "Region: #{contactData[3]}"
    #       puts "Suburb: #{contactData[4]}\n"
    #       i += 1
    #     end
    #   end
  
      print "\nEnter the number of the contact you want to edit or (X) to cancel: "
      option = gets.chomp
  
      if option == 'X' || option == 'x'
        system('exit')
      else
        id = option.to_i - 1
        numberOfContacts = conxn.getDB.exec("SELECT COUNT(id) FROM contacts")[0]['count'].to_i
        puts conxn.getDB.exec("SELECT COUNT(id) FROM contacts").inspect.to_i;

        # contacts.close
        if id >= 0 && id < numberOfContacts
        #   contact = contacts[index]
        #   contactData = contact.chomp.split(',')

        contact = conxn.getDB.exec("SELECT * FROM contacts WHERE id = #{id + 1}")[0]
  
          print "\nDo you want to edit contact with the following details? (Y/N)"
          puts "\nFirst name: #{contact['first_name']}"
          puts "Last name: #{contact['last_name']}"
          puts "Phone number: #{contact['phone_number']}"
          puts "Region: #{contact['region']}"
          puts "Suburb: #{contact['suburb']}"
  
          _option = gets.chomp

          firstName = conxn.getDB.exec("SELECT first_name FROM contacts WHERE id = #{id + 1}")[0]['first_name']
          lastName = conxn.getDB.exec("SELECT last_name FROM contacts WHERE id = #{id + 1}")[0]['last_name']
            phoneNumber = conxn.getDB.exec("SELECT phone_number FROM contacts WHERE id = #{id + 1}")[0]['phone_number']
            region = conxn.getDB.exec("SELECT region FROM contacts WHERE id = #{id + 1}")[0]['region']
            suburb = conxn.getDB.exec("SELECT suburb FROM contacts WHERE id = #{id + 1}")[0]['suburb']
  
          if _option == 'Y' || _option == 'y'
            puts "\nEnter new details"
            print "\nEnter new first name(#{firstName}): "
            newFirstName = gets.chomp
            while newFirstName == ''
                print "Do you want to keep first name as #{firstName}? (Y/N): "
                _option = gets.chomp
                if _option == 'Y' || _option == 'y'
                    newFirstName = firstName
                    break
                else
                    print "Enter new first name(#{firstName}): "
                    newFirstName = gets.chomp
                end
            end
  
            print "Enter new last name(#{lastName}): "
            newLastName = gets.chomp
            while newLastName == ''
                print "Do you want to keep last name as #{lastName}? (Y/N): "
                _option = gets.chomp
                if _option == 'Y' || _option == 'y'
                    newLastName = lastName
                    break
                else
                    print "Enter new last name(#{lastName}): "
                    newLastName = gets.chomp
                end
            end
  
            print "Enter new phone number(#{phoneNumber}): "
            newPhoneNumber = gets.chomp
            while newPhoneNumber == ''
                print "Do you want to keep phone number as #{phoneNumber}? (Y/N): "
                _option = gets.chomp
                if _option == 'Y' || _option == 'y'
                    newPhoneNumber = phoneNumber
                    break
                else
                    print "Enter new phone number(#{phoneNumber}): "
                    newPhoneNumber = gets.chomp
                end
            end
  
            print "Enter new region(#{region}): "
            newRegion = gets.chomp
            while newRegion == ''
                print "Do you want to keep region as #{region}? (Y/N): "
                _option = gets.chomp
                if _option == 'Y' || _option == 'y'
                    newRegion = region
                    break
                else
                    print "Enter new region(#{region}): "
                    newRegion = gets.chomp
                end
            end
  
            print "Enter new suburb(#{suburb}): "
            newSuburb = gets.chomp
            while newSuburb == ''
                print "Do you want to keep suburb as #{suburb}? (Y/N): "
                _option = gets.chomp
                if _option == 'Y' || _option == 'y'
                    newSuburb = suburb
                    break
                else
                    print "Enter new suburb(#{suburb}): "
                    newSuburb = gets.chomp
                end
            end
  
            puts "\nYou have entered the following new details:"
            puts "First name: #{newFirstName}"
            puts "Last name: #{newLastName}"
            puts "Phone number: #{newPhoneNumber}"
            puts "Region: #{newRegion}"
            puts "Suburb: #{newSuburb}\n"
  
            print 'Press Y to save changes or (X) to cancel: '
            _option = gets.chomp
  
            if _option == 'Y' || _option == 'y'
            #   updatedContact = "#{newFirstName.capitalize},#{newLastName.capitalize},#{newPhoneNumber},#{newRegion.capitalize},#{newSuburb.capitalize}"
            #   contacts[index] = updatedContact
  
            #   File.open('contacts.txt', 'w') { |file| file.puts(contacts) }

                conxn.getDB.exec("UPDATE contacts SET first_name = '#{newFirstName.capitalize}', last_name = '#{newLastName.capitalize}', phone_number = '#{newPhoneNumber}', region = '#{newRegion.capitalize}', suburb = '#{newSuburb.capitalize}' WHERE id = #{id + 1}")
  
              puts "\nContact edited successfully"
            end
          end
        else
          puts "\nContact not found"
        end
  
        print 'Press any key to go back to home or (X) to exit: '
        _option = gets.chomp
  
        if _option == 'X' || _option == 'x'
          system('exit')
        else
          Home.new.home
        end
      end
    end
  end  



class ViewContacts
    def viewContacts
        system('clear')
        puts "**********View Contacts**********"
        # contacts = File.new('contacts.txt', 'r')

        conxn = Home.new
        
        contacts = conxn.getDB.exec("SELECT * FROM contacts");

        if contacts.ntuples == 0
            puts "\nNo contacts found"
        else
            contacts.each_with_index do |contact, index|
                # puts "contact  #{contact.inspect}"
            
            puts "\n#{index+1}-------------------------------"
            puts "First name: #{contact['first_name']}"
            puts "Last name: #{contact['last_name']}"
            puts "Phone number: #{contact['phone_number']}"
            puts "Region: #{contact['region']}"
            puts "Suburb: #{contact['suburb']}\n"
            end
        end

        print 'Press any key to go back to home or (X) to exit: '
        option = gets.chomp
        if option == 'X' || option == 'x'
            system('exit')
        else
            Home.new.home
        end
    end
end

class DeleteContact
    def deleteContact
        system('clear')
        puts "**********Delete Contact**********\n"

        conxn = Home.new
        contacts = conxn.getDB.exec("SELECT * FROM contacts");

        if contacts.ntuples == 0
            puts "\nNo contacts found"
        else
            contacts.each_with_index do |contact, index|
                # puts "contact  #{contact.inspect}"

                puts "\n#{index+1}-------------------------------"
                puts "First name: #{contact['first_name']}"
                puts "Last name: #{contact['last_name']}"
                puts "Phone number: #{contact['phone_number']}"
                puts "Region: #{contact['region']}"
                puts "Suburb: #{contact['suburb']}\n"
            end
        end

        # contacts = File.readlines('contacts.txt')
        # i = 1
        # if contacts.empty?
        #     puts "\nNo contacts to delete"
        # else
        #     contacts.each do |contact|
        #     contact = contact.split(",")
        #     puts "\n#{i}-------------------------------"
        #     puts "First name: #{contact[0]}"
        #     puts "Last name: #{contact[1]}"
        #     puts "Phone number: #{contact[2]}"
        #     puts "Region: #{contact[3]}"
        #     puts "Suburb: #{contact[4]}\n"
        #     i += 1
        #     end
        # end
        print "\nEnter the number of the contact you want to delete or (X) to cancel: "
        option = gets.chomp
        if option == 'X' || option == 'x'
            system('exit')
        else
            id = option.to_i - 1
            numberOfContacts = conxn.getDB.exec("SELECT COUNT(id) FROM contacts")[0]['count'].to_i
            puts conxn.getDB.exec("SELECT COUNT(id) FROM contacts").inspect.to_i;
            
            if id >= 0 && id < numberOfContacts
                contact = conxn.getDB.exec("SELECT * FROM contacts WHERE id = #{id + 1}")[0]

                print "\nDo you want to delete contact with the following details? (Y/N)"
                puts "\nFirst name: #{contact['first_name']}"
                puts "Last name: #{contact['last_name']}"
                puts "Phone number: #{contact['phone_number']}"
                puts "Region: #{contact['region']}"
                puts "Suburb: #{contact['suburb']}\n"
                
                _option = gets.chomp
                if _option == 'Y' || _option == 'y'
                    # contacts.delete_at(id)
                    conxn.getDB.exec("DELETE FROM contacts WHERE id = #{id + 1}")

                    puts "\nContact deleted successfully"

                    conxn.getDB.exec("UPDATE contacts SET id= id - 1 WHERE id > #{id + 1}")

                    print 'Press any key to go back to home or (X) to exit: '
                    _option = gets.chomp

                    if _option == 'X' || _option == 'x'
                        system('exit')
                    else
                        Home.new.home
                    end
                else
                    puts 'Deleting contact cancelled'

                    print "\nPress any key to go back to home or (X) to exit: "
                    _option = gets.chomp

                    if _option == 'X' || _option == 'x'
                        system('exit')
                    else
                        Home.new.home
                    end
                end

            else
                puts "\nContact not found"
            end

            print 'Press any key to go back to home or (X) to exit: '
            _option = gets.chomp

            if _option == 'X' || _option == 'x'
                system('exit')
            else
                Home.new.home
            end
        end
    end
end

Home.new.home









