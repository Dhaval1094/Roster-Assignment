//
//  TblCell_EventList.swift
//  RosterAssignment
//
//  Created by Prince Sojitra on 16/9/19.
//  Copyright © 2019 Prince Sojitra. All rights reserved.
//

import UIKit
import FontAwesome_swift

protocol TblCell_EventListDelegate {
    func eventCellTapped(cell: TblCell_EventList)
}

class TblCell_EventList: UITableViewCell {
    
    //MARK: - @IBOutlet
    @IBOutlet var viewOuter: UIView!
    @IBOutlet weak var imgVwContent: UIImageView!
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var lblStandBy: UILabel!
    @IBOutlet var lblDescription: UILabel!
    @IBOutlet var lblDepartureArrivelTime: UILabel!
    
    //MARK: - Variable
    var delegate: TblCell_EventListDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //Initialization code
        self.lblTitle.text = ""
        self.lblDescription.text = ""
        self.lblDepartureArrivelTime.text = ""
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    //Add tap gesture to conentview to detect user action on tap
    func addTapGesture() {
        contentView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.contentView.addGestureRecognizer(tap)
    }
    
    func setWith(event: EventList) {
       lblDepartureArrivelTime.textColor = Constants.Colours.PrimaryRed
       lblTitle.textColor = Constants.Colours.Black
       lblDescription.textColor = Constants.Colours.PrimaryGrey
        
        if !event.timeArrive.isEmpty || !event.timeDepart.isEmpty {
           lblDepartureArrivelTime.text = event.timeDepart + " - " + event.timeArrive
        }
        
       lblStandBy.isHidden = true
       lblDescription.text = " "
        
        switch event.dutyCode {
        case DutyCode.Flight.rawValue:
           lblTitle.text = event.departure + " - " + event.destination
           lblDepartureArrivelTime.isHidden = false
           imgVwContent.image = UIImage.fontAwesomeIcon(name: .plane, style: .solid, textColor: UIColor.darkText, size: CGSize(width: 35.0, height: 35.0))
            break
        case DutyCode.StandBy.rawValue:
           lblTitle.text = event.dutyCode
           lblDescription.text = event.dutyCode + " (" + event.departure + ")"
           lblStandBy.isHidden = false
           lblDescription.isHidden = false
           lblDepartureArrivelTime.isHidden = false
           imgVwContent.image = UIImage.fontAwesomeIcon(name: .clipboardList, style: .solid, textColor: UIColor.darkText, size: CGSize(width: 35.0, height: 35.0))
            break
        case DutyCode.LayOver.rawValue:
           lblTitle.text = event.dutyCode
           lblDescription.text = event.departure
           lblDescription.isHidden = false
           lblDepartureArrivelTime.isHidden = false
            let iTimeDiffernece = DateFormatManager.shared.getTimeDifferenceFromString(startDate: event.timeDepart, endDate: event.timeArrive)
            
            let iHours = iTimeDiffernece.1 < 9 ? "0" + String(iTimeDiffernece.1) : String(iTimeDiffernece.1)
            let iMinutes = iTimeDiffernece.2 < 9 ? "0" + String(iTimeDiffernece.2) : String(iTimeDiffernece.2)
           lblDepartureArrivelTime.text = iHours + ":" + iMinutes + " hours"
           imgVwContent.image = UIImage.fontAwesomeIcon(name: .suitcase, style: .solid, textColor: UIColor.darkText, size: CGSize(width: 35.0, height: 35.0))
            break
        case DutyCode.Off.rawValue:
           lblTitle.text = event.dutyCode
           lblDescription.text = event.departure
           lblDepartureArrivelTime.isHidden = true
           imgVwContent.image = UIImage.fontAwesomeIcon(name: .home, style: .solid, textColor: UIColor.darkText, size: CGSize(width: 35.0, height: 35.0))
            break
        default:
            break
        }
    }
    
    //Handle Tap on cell
    @objc func handleTap() {
        delegate?.eventCellTapped(cell: self)
    }
    
}
