





Abstract (Meet & Owen)
The Green Miles project is a sustainable transportation tracking application designed for
users who want constant and clear insight into the carbon impact of their daily travels.
The application tracks low-carbon journeys made by foot, cycle, motorbike, bus or petrol
car, calculates savings against a petrol-car baseline and showcases the impact via
dashboard,  weekly  insights  charts  and  community  leaderboard.    The  platform
implements a cross-platform Flutter mobile client backed by Supabase authentication,
persistent storage and object storage. This report covers everything Group Alpha and
team did to bring together stakeholders, research, develop, test and reflect on their fully
agile delivery. The report outlines the motivations for the selected technical route, the
eight project iterations and the technical, ethical and methodological lessons learnt over
the semester. The last section describes possibilities for future work involving other
modes of transport and partner integrations on platforms.

## 1. Introduction
A. Background (Rahil)
Over the years, greenhouse gas emissions from transportation have become one of the
biggest contributors to global pollution. Similarly, a large segment of carbon dioxide
produced in Australia each year comes from transportation. More and more individual
travellers are becoming aware of the environmental cost of how they travel, but there
remains a considerable gap between intention and action. Many users would prefer to
choose a sustainable transport mode but lack a handy way to view the carbon impact of
their choice in real-time.
While existing fitness applications work on the premise of modules exercising but are not
enhancing the carbon impact as they deal with adding information in a secondary way,
while map applications are learning more about navigation than being reflective about
our past behaviour.
Green Miles was created in order to close that gap. The common goal of the application
is an area where users can record their daily trips in one simple to use application, see
how much carbon they save compared to doing the same trip by petrol car, and engage
with other like-minded users. This product has been developed with discussion from the
project  owner,  a  sustainability-focussed  stakeholder.  It  is  based  on  robust  carbon-
accounting figures that draw on publicly available emissions data for each transport
mode.
The project is technically executed as a Flutter Mobile application targeted in Android
platform  and  is  supported  by  Supabase,  which  is  practically  an  open‑source





backend‑as‑a‑service  providing  PostgreSQL  storage  and  authentication,  row‑level
security and object storage, all packaged and hosted. The architectural approach is
Model-View-ViewModel (MVVM) with provider package for state management, and all
backend call through a single Backend facade class so that the UI layer does not use
vendor-specific  imports.  The  benefit  of  maintaining  this  separation  showed  itself
repeatedly during the project when platform‑side rules changed, and only one client
method needed to be adjusted to compensate.
B. Market Analysis (Musrat)
Green Miles is made for people who want to use environmentally friendly transport and
reduce pollution, including students, workers, and community members.
Many existing apps mainly focus on fitness or navigation, but Green Miles combines trip
tracking,  carbon  saving  calculation,  environmental  awareness,  and  rewards  in  one
mobile app.
## Target Users:
- University students
- Daily commuters
- Cyclists and walkers
- Environmentally aware communities
- Smart city initiatives

## Competitor Analysis
## Competitor Features Limitation Website
Google Maps Navigation and route
tracking
No carbon reward
system
## Google Maps
Strava Fitness and activity
tracking
Mainly focused on
sports users
## Strava
MyFitnessPal Activity and calorie
tracking
No sustainability or
transport focus
MyFitnessPal
## Carbon Footprint
## Apps
Carbon emission
tracking
Limited community
interaction
## Carbon Footprint
## Apps

Competitive Advantage of Green Miles
- Carbon-saving calculation in real time
- Eco-friendly reward and credit system
- Community leaderboard and social engagement
- Offline trip support
- Educational sustainability awareness






## Market Opportunity
More  people  now  care  about  the  environment,  so  eco-friendly  apps  are  becoming
popular. Green Miles helps users choose better transport options by giving rewards,
tracking progress, and allowing friendly competition with others.

C. Aim (Rahil)
The Green Miles project aims to provide an end to end working mobile app where users
can record their sustainable transport trips, see a correct calculation of the carbon
savings  they  have  achieved  with  their  choices  and  involve  in  a  community  feature
encouraging ongoing engagement. This assignment aims to deliver the client-side Flutter
application with the Supabase database schema and triggers as a package to the project
owner.
Objectives specific to the deliverable are:
- This feature includes signing up, signing in, verifying email, resetting password by
one time pass code, changing password, deleting account, and a configuration
screen fallback in case of first run users.
- Accurate mapping of the trip with GPS-based distance and time measurement,
polyline on the screen, and the ability to continue recording when the device is in
the background.
- The carbon savings model based on published per-kilometre emission figures for
all supported transport modes, with the petrol car used as the reference baseline.
- The objective is to build an anti-cheat layer that starts issuing warnings upon
detecting  an  inconsistency  between  the  recorded  speed  and  the  selected
transport mode. If the trip is fraudulently impeded, the trip shall be cancelled for
constant multiple violations of the checks.
- A storage layer that preserves any trips you make without connectivity in an offline
first manner and uploads them when you reconnect.
- A dashboard and weekly insights screen, as well as a leaderboard that capture trip
data in an immediately understandable form.
- A settings screen that gives users useful control over their public visibility, weekly
carbon goal and account lifecycle.
D. Stakeholders (Musrat)
Stakeholder management identifies the users, teams, and organizations involved in the
Green Miles project. It explains how stakeholders interact with the application and their
role in supporting the project’s success.
Target Users of the Project





## - Who
- Students and daily commuters
- Cyclists and walkers
- People interested in sustainable transport
## - What
- Track trips using GPS
- Calculate carbon savings
- View trip statistics and rewards
## - How
- Create an account and log in
- Select transport type and start tracking
- View rankings and share progress
Internal and External Stakeholders
## Internal Stakeholders:
- Project Sponsor: Provides funding and support
- Project Manager: Manages project tasks and timeline
- Development Team: Develops the mobile app and backend
- QA/Testers: Test the system and report bugs
- Marketing Team: Promotes the application
## External Stakeholders:
- End Users: People using the application
- Environmental Organizations: Support sustainability awareness
- Cloud Service Providers: Provide backend services such as Supabase
- Government and Regulators: Ensure privacy and legal compliance





## Stakeholder Matrix
## Name Position Internal / External Project Role
## Troy Client External Project
requirements and
feedback
## Charles Project Manager Internal Project
coordination
Meet Project Lead Internal Leading project
decisions
Rahil Lead Developer Internal Mobile app and
backend
development
Rafsan Developer Internal Application feature
development
Musrat Jahan QA Tester Internal Testing and bug
reporting
Owen UX & Marketing
## Coordinator
Internal UI/UX design and
application
promotion
## Students &
## Commuters
End Users External Use the application
## Environmental
## Groups
## Sustainability
## Partners
## External Promote
sustainability
awareness
## Supabase Cloud Service
## Provider
External Backend and
authentication
services
## Government
## Agencies
Regulators External Privacy and legal
compliance


E. Approaches to Deliver Product to Client (Meet)
The project deliverables will finally consist of a single self-contained project folder with
complete source code, every single asset, all documentation, and the database scripts
needed to set up an empty Supabase project from scratch. Within the folder exist files
representing  the  local  environment  configuration  with  credentials  populated  for
development, plus a README document that guides any reviewer through the setup
process in five clearly labeled steps.
The  database  is  available  as  three  SQL  files  in  the  database  directory  to  facilitate
reproducibility. The script schema.sql is an idempotent script that creates every table,
foreign-key relationship, index, row-level security policy, trigger, and remote procedure





call used by the application. The second file, seed.sql, populates the database with 10
dummy users. Each dummy user has different trip data, trip preferences, and inbox
messages to help granularly review our application. This method allows a reviewer to
experience  our  application  without  needing  to  create  this  dataset.  The  third,
delete_seed.sql, removes dummy users while leaving the schema intact allowing the
database to be refreshed between tests. All three scripts have been implemented to be
re‑runnable. We use IF NOT EXISTS guard on tables, CREATE OR REPLACE on functions,
and explicitly clean up policies and previous seed rows before we re‑create them.
The application itself is delivered as a regular Flutter project. Reviewers may execute
flutter pub get to install dependencies, optionally regenerate the launcher icons with the
flutter_launcher_icons  package, and  then  launch  the  application  on  any  connected
Android device or emulator.  This folder excludes any regenerated build artefacts and IDE
settings, ensuring that the delivered folder contains human−authored source files only.

- Methodology (Musrat)
Green Miles followed an Agile development methodology. The project work was divided
into multiple iterations (sprints) to manage development, testing, and improvements
step by step.
The team used Jira to:
- Manage tasks and deadlines
- Track sprint progress
- Assign responsibilities to team members
- Report bugs and monitor development progress
Each iteration focused on different features and improvements of the application.
A. Product Backlog (Musrat)
For this section, your lecturer is asking for a simple overview of how your team used
Agile methodology and Jira during the project.
You do not need a complex theory explanation.
You mainly need:
- Short explanation of Agile + Jira
- Screenshots of Jira iterations/sprints
- Small explanation of what the team completed in each iteration
You can structure it like this:






## Methodology
Green Miles followed an Agile development methodology. The project work was divided
into multiple iterations (sprints) to manage development, testing, and improvements
step by step.
The team used Jira to:
- Manage tasks and deadlines
- Track sprint progress
- Assign responsibilities to team members
- Report bugs and monitor development progress
Each iteration focused on different features and improvements of the application.
## Product Backlog
The product backlog contained all planned features, testing tasks, UI improvements,
and bug fixes for the Green Miles application.
Figure 1: Jira Product Backlog and Sprint Management





Figure 2:  Timeline of Jira Product

Figure 3:  Active Sprint of Jira Product
## Iteration Overview
## Iteration Tasks Completed
Iteration 1 Project research and requirement gathering Initial planning and feature
discussionFigma prototype and UI design preparation
Iteration 2 Login and profile system developmentDashboard and navigation UI
developmentInitial testing preparation





Iteration 3 GPS tracking and map integrationCarbon calculation featureBasic trip
tracking testing
Iteration 4 Leaderboard and notification featuresBug fixing and UI
improvementsTransport mode testing
Iteration 5 Trip history and profile updatesQA testing and bug reportingReal-time
update improvements
Iteration 6 Final testing and bug fixingPerformance checkingDeployment
preparation and final review

B. Release Plan (Rafsan)

C.  Updates from Each Iteration/Sprint (Everyone)
## Iteration Musrat Jahan
(QA Tester)
## Owen
(UX/UI Tester)
## Meet Rahil Rafsan
## Iteration
## 1
## Researched
similar apps,
gathered
requirements,
helped review
## Figma
prototype
Designed app UI
mock-up in
## Figma

## Iteration
## 2
## Supported
## UI/UX
improvements,
reviewed
navigation,
prepared test
cases
Updated the
Figma design
based on
iteration 1’s
feedback

## Iteration
## 3
## Tested
notifications,
rankings, map
functions, and
reported bugs
Tested the
tracking trip
function,
checked for
UX/UI errors

## Iteration
## 4
Tested GPS
tracking, trip
recording, and
reported trip
history issues
Tested the
updated
version, made
iteration 4’s bug
report

## Iteration
## 5
Tested profile
photo upload,
trip history, and
trip switching
issues
Made iteration
5’s bug report,
give feedback to
## UX/UI
improvements






## Iteration
## 6
Performed final
QA testing, bug
re-testing, and
deployment
support
Performed final
QA testing and
bug report



## Musrat :
## Iteration 1: Research & Planning
- Researched similar GPS and sustainability applications
- Helped gather project requirements and ideas
- Supported Figma UI prototype planning and screen review
Iteration 2: UI/UX Prototype Support
- Helped improve UI/UX prototype design in Figma
- Reviewed app navigation and layout structure
- Prepared initial test cases for core features
## Iteration 3: Initial Feature Testing
- Tested notifications, ranking page, settings, and map functions
- Reported issues related to tracking and non-working features
- Verified transport mode selection and leaderboard navigation
Iteration 4: GPS & Trip Tracking Testing
- Tested GPS tracking and trip recording functions
- Verified start/stop trip features and map tracking
- Reported bug where trip history was not saving properly
## Iteration 5 : Advanced Testing & Bug Reporting
- Tested trip history, profile photo upload, and notifications
- Identified real-time update issues in trip history
- Reported trip switching and tracking reset problems
Iteration 6: Final QA Testing
- Performed final QA and usability testing
- Re-tested reported bugs after fixes





- Supported final deployment and system verification

D. Reports (Sprint Report and Burndown Chart) (Owen)
## 3. Conclusion ( Rafsan)
The Green Miles project delivered every essential item on the initial product backlog
along with the majority of the desirable items. These upgrades were packaged together
with clean code, extensive documentation, and the fully reproducible database setup.
The  app  logs  journeys,  calculates  carbon  savings,  displays  all  information  via  an
attractive graphical user interface, ranks the user based on the community, and protects
their privacy through opt￼in visibility and a self￼service account￼deletion system. The
developers took the smart decision of selecting a Supabase backend, which has a row-
level security model built-in. As a result, they achieve multi-user data isolation without
having to write a single server-side endpoint. The triggers provided by Supabase allow
expensive bookkeeping (totals, inbox messages) to live close to the data.
## A. Lessons Learnt
Tester (Musrat)
- Learned the importance of teamwork and communication during software
development
- Understood how good planning helps a project run smoothly and complete on
time
- Learned that GPS tracking features need repeated testing
- Gained knowledge about the importance of privacy and security in mobile
applications
- Learned that regular testing helps identify and fix bugs early
- Understood the concept of how sustainable applications can encourage people
to be more environmentally aware and make eco-friendly choices

## B. Ethical Consideration
Team Member (Musrat)
- User location and personal data must be kept private and not misused
- All user data should be stored securely to prevent unauthorized access
- Users should have control over what information they want to share
- The app should clearly show how carbon savings are calculated





- Transport verification should be easy to understand so users know why it is
used
- The system should stop fake trips and cheating to keep results fair
- Leaderboards must be fair so all users have equal chance to compete
- The app should be accessible and easy to use for all users
- A simple design and clear navigation should improve user experience
- The app should promote environmentally friendly transport choices
responsibly
- Carbon emission data should be accurate, honest, and based on reliable
sources

C. Further Work (Owen & Rahil)
The project has a lot of potential for future growth in various directions once immediate
delivery is completed. The reward-redemption flow is a sophisticated feature. The current
build has set the rewards table to browse-only mode, but the data model and screen
layout are practically ready for a redemption pipeline. An upcoming version may bring
back  the  points  balance  on  user  profiles,  implement  a  redeem_reward  RPC  in  the
database, and utilize the inbox framework for displaying redemption confirmations. It
would be possible to plug in partner-supplied rewards, such as discount codes, vouchers
and charitable contributions into the same flow without additional schema changes.
Additional means of transport are another candidate. The current build allows walking,
cycling, motorbike, bus, and petrol car, but the transport_mode enumerated type is easy
to extend. In the future we might have a train, ferry, EV, and e-bike. Every new format
would require an agreed upon per–kilometre emissions figure, an icon and label, an entry
in the speed–cap table used by the anti–cheat layer, and an addition to the database
enumeration.
Support for more than one platform. The existing build is intended for Android only. The
codebase is pure Flutter, and the only portion of the codebase that contains platform-
specific code is the battery-unrestrict module, which is already guarded by a platform
check. Incorporating an iOS target would primarily mean creating the platform folder and
adjusting the foreground‑service approach to iOS’s always‑on location permissions.
Ultimately, joining institutions could allow a collaborative collection of Analytics. Using
anonymized  aggregate  information,  a  partnering  local  council  or  environmental
organization could ascertain the effectiveness of an active-transport initiative within a
geographic area without the identification of individual users. To create this, a slight
modification to the database will do   a new view to expose counts above a minimum
threshold participation. Furthermore, a service-role-authenticated dashboard will be
created, completely separate from the user-facing client.





## 4. References
Chowdhury, M., Tushi, T.H. and Ilman, R., 2025, April. Stakeholder: A Carbon Footprint
Reduction Assistance Smartphone Application With Decarbonisation Plan and Carbon
Tracking Features. In 2025 4th OPJU International Technology Conference (OTCON) on
Smart Computing for Innovation and Advancement in Industry 5.0 (pp. 1-6). IEEE.
Github n.d., Green Miles App,  https://github.com/Musrat-Jahan/Green_Miles_App.git
Grammerly n.d., Grammar Checker, https://app.grammarly.com/
Heripracoyo, S., Imawan, F.Z. and Adikusumo, L.W., 2024, April. Design of the mobile
application to reduce the carbon track. In IOP Conference Series: Earth and
Environmental Science (Vol. 1324, No. 1, p. 012005). IOP Publishing.
Jira n.d., COTTA board,
https://musratjahan09.atlassian.net/jira/software/c/projects/COTTA/boards
OpenAI 2023, ChatGPT (version GPT-3.5), Search, https://chatgpt.com
