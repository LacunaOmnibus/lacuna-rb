# encoding: utf-8

require 'optparse'

require 'lacuna_util/task'
require 'lacuna_util/logger'

class UpgradeBuildings < LacunaUtil::Task

    def args
        args = {
            :dry_run => false,
            :skip    => '',
            :max_time => 2 * 24 * 60 * 60, # 2 days
        }

        OptionParser.new do |opts|

            opts.on("-d", "--dry_run", "Run, showing actions, but not changing anything.") do
                args[:dry_run] = true
            end

            opts.on("-s", "--skip PLANET", "Skip one planet.") do |name|
                args[:skip] = name.to_s
            end

            opts.on("-m", "--max-time TIME", "Max build time (seconds).") do |time|
                args[:max_time] = time.to_i
            end

        end.parse!

        args
    end

    def _run(args, config)
        Lacuna::Empire.planets.each do |id, name|

            # Give the screen some space..
            print "\n\n"

            if name == args[:skip]
                Logger.log "Skipping #{name} according to command line option..."
                next
            end

            catch :planet do
                Logger.log "Looking on #{name} for buildings to upgrade."
                buildings = Lacuna::Body.get_buildings(id)['buildings']

                # Save total build queue time for later.
                queue_time = self.get_build_queue_time(buildings)

                puts "queue : #{queue_time}, max : #{args[:max_time]}"

                UPGRADES.each do |upgrade|
                    builds = Lacuna::Body.find_buildings(buildings, upgrade[:name])
                    next if builds.nil?

                    # find_buildings returns the buildings sorted. We want to
                    # upgrade the lower levels first. So, reverse the list.
                    builds = builds.reverse

                    builds.each do |build|
                        next unless upgrade[:level] > build['level'].to_i
                        next unless build['pending_build'].nil?

                        to_upgrade = Lacuna::Buildings.url2class(build['url'])

                        # Make sure the queue isn't too full. Note: in dry-run,
                        # this check doesn't occur.
                        if queue_time >= args[:max_time] && !args[:dry_run]
                            Logger.log "Build queue full enough."
                            throw :planet
                        end

                        # Do the dirty work
                        to_level = build['level'].to_i + 1
                        Logger.log "Upgrading #{build['name']} to #{to_level}!"
                        next if args[:dry_run] # Handle dry run.
                        rv = to_upgrade.upgrade build['id']

                        unless rv['building'].nil?
                            # Add this building to the total time so that we
                            # don't just fill up the build queue isn't of stopping
                            # at the right time.
                            queue_time += rv['building']['pending_build']['seconds_remaining'].to_i
                        else
                            # Handle the multiple errors here!
                            if rv['message'] =~ /no room left in the build queue/
                                # Move to the next planet.
                                throw :planet
                            else
                                Logger.log 'Unknown Error'
                                p rv
                            end
                        end
                    end
                end
            end
        end
    end

    def get_build_queue_time(buildings)
        times = []
        buildings.each do |id, building|
            unless building['pending_build'].nil?
                times << building['pending_build']['seconds_remaining'].to_i
            end
        end

        # The last item in the queue will include the times of all the other builds.
        times.sort.last || 0
    end

    UPGRADES = [

        #####################
        ### Essentials!!! ###
        #####################

        {
            :name  => 'Oversight Ministry',
            :level => 30,
        },
        {
            :name  => 'Archaeology Ministry',
            :level => 30,
        },
        {
            :name  => 'Development Ministry',
            :level => 30,
        },

        #################
        ### Tyleon!!! ###
        #################

        {
            :name  => 'Lost City of Tyleon (A)',
            :level => 30,
        },
        {
            :name  => 'Lost City of Tyleon (B)',
            :level => 30,
        },
        {
            :name  => 'Lost City of Tyleon (C)',
            :level => 30,
        },
        {
            :name  => 'Lost City of Tyleon (D)',
            :level => 30,
        },
        {
            :name  => 'Lost City of Tyleon (E)',
            :level => 30,
        },
        {
            :name  => 'Lost City of Tyleon (F)',
            :level => 30,
        },
        {
            :name  => 'Lost City of Tyleon (G)',
            :level => 30,
        },
        {
            :name  => 'Lost City of Tyleon (H)',
            :level => 30,
        },
        {
            :name  => 'Lost City of Tyleon (I)',
            :level => 30,
        },

        ################
        ### Spies!!! ###
        ################

        {
            :name  => 'Intelligence Ministry',
            :level => 30,
        },
        {
            :name  => 'Security Ministry',
            :level => 30,
        },
        {
            :name  => 'Espionage Ministry',
            :level => 30,
        },
        {
            :name  => 'Intel Training',
            :level => 30,
        },
        {
            :name  => 'Mayhem Training',
            :level => 30,
        },
        {
            :name  => 'Politics Training',
            :level => 30,
        },
        {
            :name  => 'Theft Training',
            :level => 30,
        },

        #########################
        ### Space Station Lab ###
        #########################

        {
            :name  => 'Space Station Lab (A)',
            :level => 20,
        },
        {
            :name  => 'Space Station Lab (B)',
            :level => 20,
        },
        {
            :name  => 'Space Station Lab (C)',
            :level => 20,
        },
        {
            :name  => 'Space Station Lab (D)',
            :level => 20,
        },

        ################
        ### Ships!!! ###
        ################

        {
            :name  => 'Shipyard',
            :level => 30,
        },
        {
            :name  => 'Trade Ministry',
            :level => 30,
        },
        {
            :name  => 'Propulsion System Factory',
            :level => 30,
        },
        {
            :name  => 'Cloaking Lab',
            :level => 30,
        },
        {
            :name  => 'Observatory',
            :level => 30,
        },
        {
            :name  => 'Terraforming Lab',
            :level => 30,
        },
        {
            :name  => 'Gas Giant Lab',
            :level => 30,
        },
        {
            :name  => 'Pilot Training Facility',
            :level => 30,
        },
        {
            :name  => 'Munitions Lab',
            :level => 30,
        },
        {
            :name  => 'Embassy',
            :level => 30,
        },
        {
            :name  => 'Planetary Command Center',
            :level => 30,
        },
        {
            :name  => 'Waste Sequestration Well',
            :level => 30,
        },

        #######################
        ### All The Rest!!! ###
        #######################

        {
            :name  => 'Shield Against Weapons',
            :level => 30,
        },
        {
            :name => 'Mission Command',
            :level => 30,
        },
        {
            :name => 'Entertainment District',
            :level => 30,
        },
        {
            :name  => 'Subspace Transporter',
            :level => 30,
        },
        {
            :name  => 'Food Reserve',
            :level => 30,
        },
        {
            :name  => 'Ore Storage Tanks',
            :level => 30,
        },
        {
            :name  => 'Water Storage Tank',
            :level => 30,
        },
        {
            :name  => 'Energy Reserve',
            :level => 30,
        },
        {
            :name  => 'Space Port',
            :level => 28,
        },
    ]
end

LacunaUtil.register_task UpgradeBuildings
