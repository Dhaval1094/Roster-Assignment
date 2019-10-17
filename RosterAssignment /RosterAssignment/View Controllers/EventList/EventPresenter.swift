//
//  EventPresenter.swift
//  RosterAssignment
//
//  Created by Prince Sojitra on 17/09/19.
//  Copyright © 2019 Prince Sojitra. All rights reserved.
//

import UIKit
import Foundation
import RealmSwift
import Realm

protocol EventView: NSObjectProtocol {
    func setEvents(_ eventsSections: [String], eventsSectionItems:[[EventList]])
    func setEmptyEventsMessage()
    func setAvailableEventsMessage()
    func showErrorMessage(strErrorMEssage:String)
    func showEventDetails(nextPresenter: EventDetailsPresenter)
}

//Coordinate with view & model as well update them respectivily based on user action.
class EventPresenter {
    
    let eventService:EventService
    var eventView : EventView?
    private var eventSections = [String]()
    private var eventSectionItems = [[EventList]]()
    
    init(service:EventService){
        self.eventService = service
    }
    
    func attachView(_ view:EventView){
        self.eventView = view
    }
    
    func detachView() {
        eventView = nil
    }
    
    //Get events data from server side, write on realm database for offline use and update the view
    func getEvents(){
        
        
        if ConnectionCheck.isConnectedToInternet() {
            //Get events data from server side and update the view
            self.eventView?.setAvailableEventsMessage()
            eventService.getEvents { [weak self] events,error   in
                
                guard error == nil else {
                    switch error {
                    case .connectionError?:
                        self?.eventView?.showErrorMessage(strErrorMEssage: Constants.Messages.NoInternet)
                        break
                    default:
                        self?.eventView?.showErrorMessage(strErrorMEssage: Constants.Messages.Error)
                        break
                    }
                    return
                }
                
                self?.checkEventsDataExistToDisplay(events: events)
            }
        }
        else {
            //Get events data from realm database and update the view
            eventService.getEventsFromRealm { [weak self] events,error   in
                
                self?.eventView?.showErrorMessage(strErrorMEssage: Constants.Messages.NoInternet)
                
                self?.checkEventsDataExistToDisplay(events: events)
            }
            
        }
    }
    
    //Check evnets data exist or not
    func checkEventsDataExistToDisplay(events:Results<EventList>?) {
        
        if let eventsList = events {
            if eventsList.count == 0 {
                self.eventView?.setEmptyEventsMessage()
            }
            else {
                self.filterEventsDateWise(eventsToDisplay: eventsList)
            }
        }
        else {
            self.eventView?.setEmptyEventsMessage()
        }
    }
    
    //Filter events based on date
    func filterEventsDateWise(eventsToDisplay:Results<EventList>){
        
        //Events Group By Date
        let eventsToDisplayByDate = Dictionary(grouping: eventsToDisplay, by: {  $0.date })
        
        //Sorted Events Group By Date
        let getDateFormatter = DateFormatManager.shared.getDateFormat(stringFormat: Constants.DateFormatter.EventGetDate)
        let sortedByDateEventsTodisplay = eventsToDisplayByDate.sorted(by: { getDateFormatter.date(from:$0.key!)?.compare(getDateFormatter.date(from:$1.key!) ?? Date()) == .orderedDescending })
        
        //Events Sections & Section Items
        self.eventSections =  sortedByDateEventsTodisplay.map{$0.key!}
        self.eventSectionItems = sortedByDateEventsTodisplay.map{$0.value}
        
        //Notify view to display events
        self.eventView?.setEvents( self.eventSections, eventsSectionItems: self.eventSectionItems)
    }
    
    //Setup and configure the cell based on event data and render it to the user
    func configureEventCell(cell:TblCell_EventList,indexPath: IndexPath){
        let event = self.eventSectionItems[indexPath.section][indexPath.row]
        cell.setWith(event: event)
    }
    
    //Setup and configure the cell based on event header data and render it to the user
    func configureEventHeaderCell(cell:TblCell_EventListHeader,section: Int){
        let eventHeader = self.eventSections[section]
        let iStrDate = DateFormatManager.shared.dateStringPrintable(strDate: eventHeader, getFormat: Constants.DateFormatter.EventGetDate, printFormat: Constants.DateFormatter.EventPrintDate)
        cell.lblTitle.text = iStrDate
    }
    
    //Get the event detials based on user tapped and preapre the event deatils vc to push
    func showEventDetails(indexPath: IndexPath) {
        let eventSection = self.eventSections[indexPath.section]
        let sectionItem = self.eventSectionItems[indexPath.section][indexPath.row]
        let dicteEventDetails  = [eventSection:sectionItem]
        let eventDetailsPresenter = EventDetailsPresenter(eventDetails: dicteEventDetails)
        self.eventView?.showEventDetails(nextPresenter: eventDetailsPresenter)
    }
}
