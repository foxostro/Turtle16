//
//  SchematicLevelCPUModel.swift
//  TurtleSimulatorCore
//
//  Created by Andrew Fox on 12/30/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import Foundation

// Models the Turtle16 CPU. Please refer to MainBoard.sch for details.
// Classes in the simulator intentionally model specific pieces of hardware,
// following naming conventions and organization that matches the schematics.
public class SchematicLevelCPUModel: NSObject, CPU {
    public static var supportsSecureCoding = true
    public static let kNumberOfResetCycles: UInt = 100 // fake, but whatever

    public var timeStamp: UInt = 0
    public var resetCounter: UInt = kNumberOfResetCycles

    public var isResetting: Bool {
        resetCounter > 0
    }

    public var isHalted: Bool {
        outputEX.hlt == 0
    }

    public var isStalling: Bool {
        outputID.stall & 1 != 0
    }

    public var pc: UInt16 = 0
    var prevPC: UInt16 = 0

    public var instructions: [UInt16] = .init(repeating: 0, count: 65535)

    public var decoder: InstructionDecoder {
        set(value) {
            stageID.decoder = value
        }
        get {
            stageID.decoder
        }
    }

    public var n: UInt = 0
    public var c: UInt = 0
    public var z: UInt = 0
    public var v: UInt = 0

    public let numberOfRegisters = 8

    public func setRegister(_ idx: Int, _ val: UInt16) {
        assert(idx >= 0 && idx < numberOfRegisters)
        stageID.registerFile[idx] = val
    }

    public func getRegister(_ idx: Int) -> UInt16 {
        assert(idx >= 0 && idx < numberOfRegisters)
        return stageID.registerFile[idx]
    }

    public var load: (MemoryAddress) -> UInt16 {
        get {
            stageMEM.load
        }
        set(newValue) {
            stageMEM.load = newValue
        }
    }

    public var store: (UInt16, MemoryAddress) -> Void {
        get {
            stageMEM.store
        }
        set(newValue) {
            stageMEM.store = newValue
        }
    }

    public let numberOfPipelineStages = 5

    public func getPipelineStageInfo(_ idx: Int) -> PipelineStageInfo {
        assert(idx >= 0 && idx < numberOfPipelineStages)
        return switch idx {
        case 0:
            PipelineStageInfo(
                name: "IF",
                pc: stageIF.associatedPC,
                status: "\(outputIF)"
            )
        case 1:
            PipelineStageInfo(
                name: "ID",
                pc: stageID.associatedPC,
                status: "\(outputID)"
            )
        case 2:
            PipelineStageInfo(
                name: "EX",
                pc: stageEX.associatedPC,
                status: "\(outputEX)"
            )
        case 3:
            PipelineStageInfo(
                name: "MEM",
                pc: stageMEM.associatedPC,
                status: "\(outputMEM)"
            )
        case 4:
            PipelineStageInfo(
                name: "WB",
                pc: stageWB.associatedPC,
                status: "\(outputWB)"
            )
        default:
            fatalError("unreachable")
        }
    }

    public let stageIF: IF
    public let stageID: ID
    public let stageEX: EX
    public let stageMEM: MEM
    public let stageWB: WB

    public var outputIF: IF_Output
    public var outputID: ID_Output
    public var outputEX: EX_Output
    public var outputMEM: MEM_Output
    public var outputWB: WB_Output

    public override init() {
        stageIF = IF()
        stageID = ID()
        stageEX = EX()
        stageMEM = MEM()
        stageWB = WB()

        outputIF = IF_Output(ins: 0, pc: 0)
        outputID = ID_Output(stall: 0, ctl_EX: 0b11111_11111111_11111111, a: 0, b: 0, ins: 0)
        outputEX = EX_Output(
            n: 0,
            c: 0,
            z: 0,
            v: 0,
            j: 1,
            jabs: 1,
            y: 0,
            hlt: 1,
            storeOp: 0,
            ctl: 0b11111_11111111_11111111,
            selC: 0
        )
        outputMEM = MEM_Output(y: 0, storeOp: 0, selC: 0, ctl: 0b11111_11111111_11111111)
        outputWB = WB_Output(c: 0, wrl: 1, wrh: 1, wben: 1)

        super.init()
        stageIF.load = { [weak self] (addr: UInt16) in
            if addr < self!.instructions.count {
                return self!.instructions[Int(addr)]
            }
            return 0
        }

        //        stageID.decoder = ProgrammableLogicDecoder()
        let rom = OpcodeDecoderROM()
        rom.opcodeDecodeROM = DecoderGenerator().generate()
        stageID.decoder = rom
    }

    public required init?(coder: NSCoder) {
        guard let timeStamp = coder.decodeObject(forKey: "timeStamp") as? UInt,
              let resetCounter = coder.decodeObject(forKey: "resetCounter") as? UInt,
              let pc = coder.decodeObject(forKey: "pc") as? UInt16,
              let prevPC = coder.decodeObject(forKey: "prevPC") as? UInt16,
              let instructions = coder.decodeObject(forKey: "instructions") as? [UInt16],
              let n = coder.decodeObject(forKey: "n") as? UInt,
              let c = coder.decodeObject(forKey: "c") as? UInt,
              let v = coder.decodeObject(forKey: "v") as? UInt,
              let z = coder.decodeObject(forKey: "z") as? UInt,
              let stageIF = coder.decodeObject(of: IF.self, forKey: "stageIF"),
              let stageID = coder.decodeObject(of: ID.self, forKey: "stageID"),
              let stageEX = coder.decodeObject(of: EX.self, forKey: "stageEX"),
              let stageMEM = coder.decodeObject(of: MEM.self, forKey: "stageMEM"),
              let stageWB = coder.decodeObject(of: WB.self, forKey: "stageWB"),
              let outputIF = coder.decodeObject(of: IF_Output.self, forKey: "outputIF"),
              let outputID = coder.decodeObject(of: ID_Output.self, forKey: "outputID"),
              let outputEX = coder.decodeObject(of: EX_Output.self, forKey: "outputEX"),
              let outputMEM = coder.decodeObject(of: MEM_Output.self, forKey: "outputMEM"),
              let outputWB = coder.decodeObject(of: WB_Output.self, forKey: "outputWB")
        else {
            return nil
        }
        self.timeStamp = timeStamp
        self.resetCounter = resetCounter
        self.pc = pc
        self.prevPC = prevPC
        self.instructions = instructions
        self.n = n
        self.z = z
        self.c = c
        self.v = v
        self.stageIF = stageIF
        self.stageID = stageID
        self.stageEX = stageEX
        self.stageMEM = stageMEM
        self.stageWB = stageWB
        self.outputIF = outputIF
        self.outputID = outputID
        self.outputEX = outputEX
        self.outputMEM = outputMEM
        self.outputWB = outputWB

        super.init()

        self.stageIF.load = { [weak self] (addr: UInt16) in
            if addr < self!.instructions.count {
                return self!.instructions[Int(addr)]
            }
            return 0
        }
    }

    public func encode(with coder: NSCoder) {
        coder.encode(timeStamp, forKey: "timeStamp")
        coder.encode(resetCounter, forKey: "resetCounter")
        coder.encode(pc, forKey: "pc")
        coder.encode(prevPC, forKey: "prevPC")
        coder.encode(instructions, forKey: "instructions")
        coder.encode(n, forKey: "n")
        coder.encode(z, forKey: "z")
        coder.encode(c, forKey: "c")
        coder.encode(v, forKey: "v")
        coder.encode(stageIF, forKey: "stageIF")
        coder.encode(stageID, forKey: "stageID")
        coder.encode(stageEX, forKey: "stageEX")
        coder.encode(stageMEM, forKey: "stageMEM")
        coder.encode(stageWB, forKey: "stageWB")
        coder.encode(outputIF, forKey: "outputIF")
        coder.encode(outputID, forKey: "outputID")
        coder.encode(outputEX, forKey: "outputEX")
        coder.encode(outputMEM, forKey: "outputMEM")
        coder.encode(outputWB, forKey: "outputWB")
    }

    public static func decode(from data: Data) throws -> SchematicLevelCPUModel {
        var decodedObject: SchematicLevelCPUModel? = nil
        let unarchiver = try NSKeyedUnarchiver(forReadingFrom: data)
        unarchiver.requiresSecureCoding = false
        decodedObject = unarchiver.decodeObject(of: self, forKey: NSKeyedArchiveRootObjectKey)
        if let error = unarchiver.error {
            fatalError(
                "Error occured while attempting to decode \(self) from data: \(error.localizedDescription)"
            )
        }
        guard let decodedObject else {
            fatalError("Failed to decode \(self) from data.")
        }
        return decodedObject
    }

    public static func == (lhs: SchematicLevelCPUModel, rhs: SchematicLevelCPUModel) -> Bool {
        lhs.isEqual(rhs)
    }

    public override func isEqual(_ rhs: Any?) -> Bool {
        guard rhs != nil else {
            return false
        }
        guard let rhs = rhs as? SchematicLevelCPUModel else {
            return false
        }
        guard timeStamp == rhs.timeStamp,
              resetCounter == rhs.resetCounter,
              pc == rhs.pc,
              prevPC == rhs.prevPC,
              instructions == rhs.instructions,
              n == rhs.n,
              c == rhs.c,
              v == rhs.v,
              z == rhs.z,
              numberOfRegisters == rhs.numberOfRegisters,
              numberOfPipelineStages == rhs.numberOfPipelineStages,
              stageIF == rhs.stageIF,
              stageID == rhs.stageID,
              stageEX == rhs.stageEX,
              stageMEM == rhs.stageMEM,
              stageWB == rhs.stageWB,
              outputIF == rhs.outputIF,
              outputID == rhs.outputID,
              outputEX == rhs.outputEX,
              outputMEM == rhs.outputMEM,
              outputWB == rhs.outputWB
        else {
            return false
        }
        return true
    }

    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(timeStamp)
        hasher.combine(resetCounter)
        hasher.combine(pc)
        hasher.combine(prevPC)
        hasher.combine(instructions)
        hasher.combine(n)
        hasher.combine(z)
        hasher.combine(c)
        hasher.combine(v)
        hasher.combine(numberOfRegisters)
        hasher.combine(numberOfPipelineStages)
        hasher.combine(stageIF)
        hasher.combine(stageID)
        hasher.combine(stageEX)
        hasher.combine(stageMEM)
        hasher.combine(stageWB)
        hasher.combine(outputIF)
        hasher.combine(outputID)
        hasher.combine(outputEX)
        hasher.combine(outputMEM)
        hasher.combine(outputWB)
        return hasher.finalize()
    }

    public func reset() {
        resetCounter = SchematicLevelCPUModel.kNumberOfResetCycles
        while isResetting {
            step()
        }
        timeStamp = 0
    }

    public func run(until date: Date = Date.distantFuture) -> Bool {
        repeat {
            step()
            if Date.now > date {
                return false
            }
        } while !isHalted
        return true
    }

    public func run() {
        repeat {
            step()
        } while !isHalted
    }

    public func step() {
        let rst: UInt = isResetting ? 0 : 1

        // WB
        let inputWB = WB.Input(
            y: outputMEM.y,
            storeOp: outputMEM.storeOp,
            ctl: outputMEM.ctl,
            associatedPC: outputMEM.associatedPC
        )
        outputWB = stageWB.step(input: inputWB)

        let inputWriteBack = ID.WriteBackInput(
            c: outputWB.c,
            wrh: outputWB.wrh,
            wrl: outputWB.wrl,
            wben: outputWB.wben,
            selC_WB: outputMEM.selC
        )
        stageID.writeBack(input: inputWriteBack)

        // MEM
        let inputMEM = MEM.Input(
            rdy: 0,
            y: outputEX.y,
            storeOp: outputEX.storeOp,
            selC: outputEX.selC,
            ctl: outputEX.ctl,
            associatedPC: outputEX.associatedPC
        )
        outputMEM = stageMEM.step(input: inputMEM)

        // EX
        let inputEX = EX.Input(
            pc: outputIF.pc,
            ctl: outputID.ctl_EX,
            a: outputID.a,
            b: outputID.b,
            ins: outputID.ins,
            associatedPC: outputID.associatedPC
        )
        outputEX = stageEX.step(input: inputEX)

        // ID
        let inputID = ID.Input(
            ins: outputIF.ins,
            y_EX: outputEX.y,
            y_MEM: outputMEM.y,
            ins_EX: outputID.ins,
            ctl_EX: inputEX.ctl,
            selC_MEM: inputMEM.selC,
            ctl_MEM: inputMEM.ctl,
            j: (inputEX.ctl >> 12) & 1,
            n: n,
            c: c,
            z: z,
            v: v,
            associatedPC: outputIF.associatedPC
        )
        outputID = stageID.step(input: inputID)

        // Only update flags if the appropriate bit in the control word is set.
        if ((inputEX.ctl >> DecoderGenerator.FI) & 1) == 0 {
            n = outputEX.n
            c = outputEX.c
            z = outputEX.z
            v = outputEX.v
        }

        // IF
        let inputIF = IF.Input(
            stall: outputID.stall,
            y: outputEX.y,
            jabs: outputEX.jabs,
            j: outputEX.j,
            rst: rst
        )
        outputIF = stageIF.step(input: inputIF)
        prevPC = pc
        pc = outputIF.pc

        if resetCounter > 0 {
            resetCounter = resetCounter - 1
        }

        timeStamp = timeStamp + 1
    }
}
