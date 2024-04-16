'use client';

import StepOne, { StepOneParams } from "@/components/step-1";
import { Item } from "@/models/item.models";
import { useState, useEffect } from "react";
import { Steps } from 'antd';
import StepTwo, { StepTwoParams } from "@/components/step-2";
import { ArrowLeftOutlined, ArrowRightOutlined } from '@ant-design/icons';
import { Person } from "@/models/person.models";
import StepThree, { StepThreeParams } from "@/components/step-3";
import { SplitDictionary } from "@/models/split.models";
import StepFour, { StepFourParams } from "@/components/step-4";
import { Result } from "@/models/results.models";

const STEPS = ['Add Items', 'Add People', 'Assign People & Items', 'Review & Split'];

export default function Home() {

  const [currentStep, setCurrentStep] = useState(0);
  const [items, setItems] = useState<Item[]>([]);
  const [people, setPeople] = useState<Person[]>([]);
  const [splitDict, setSplitDict] = useState<SplitDictionary>({});
  const [results, setResults] = useState<Result[]>([]);
  const [saveFriends, setSaveFriends ] = useState<boolean>(false);
  const steps = STEPS.map(each => ({ title: each }));

  useEffect(() => {
    setCurrentStep(0);
    setItems([ new Item({}) ]);

    const friends = localStorage.getItem('friends') || '';
    if (friends) {
      setPeople(JSON.parse(friends).map((each: Person) => new Person(each)));
      setSaveFriends(true);
    } else {
      setPeople([ new Person({}) ]);
      setSaveFriends(false);
    }
  }, []);

  function goNext(): void {
    switch (currentStep) {
      case 0:
        if (isStepOneValid()) {
          setCurrentStep(1);
        }
        break;
      case 1:
        if (saveFriends) {
          localStorage.setItem('friends', JSON.stringify(people));
        }
        setCurrentStep(2);
        break;
      case 2:
        calculateResults()
        setCurrentStep(3);
        break;
      case 3:
        break;
    }
  }

  function goBack(): void {
    if (currentStep > 0) {
      setCurrentStep(currentStep - 1);
    }
  }

  function isStepOneValid(): boolean {
    const checkingItems = items.map(each => {
      each.isValid();
      return each;
    });
    const isValid = checkingItems.every(each => each.isValid());
    if (isValid) {
      return true;
    }
    setItems([...checkingItems]);
    return false;
  }

  function getCurrentUI(): JSX.Element {
    switch (currentStep) {
      case 0:
        return <StepOne params={stepOneParams} />;
      case 1:
        return <StepTwo params={stepTwoParams} />;
      case 2:
        return <StepThree params={stepThreeParams} />;
      case 3:
        return <StepFour params={stepFourParams} />;
      default:
        return <div>Not Implemented yet!</div>;
    }
  }

  function calculateResults(): void {
    const itemDict: { [key in string]: Item} = {};
    items.forEach((each, index) => itemDict[index.toString()] = each); 

    const personDict: { [key in string]: {
      person: Person,
      result: Result
    }} = {};
    people.forEach((each, index) => {
      personDict[index.toString()] = {
        person: each,
        result: new Result({
          person: each,
          total: 0,
          items: []
        })
      };
    });

    Object.keys(splitDict).forEach((itemIndex) => { // [ {'0': Split Obj, '1': Split Obj} ] -> [0, 1]
      const split = splitDict[itemIndex]; // Split Obj
      const peopleIndexes = Array.from(split.sharingPersonIndex); // [0, 1]
      peopleIndexes.forEach((personIndex) => {
        const person = personDict[personIndex.toString()]; // { person: Person, result: Result }
        const item = itemDict[itemIndex]; // Get Item Object
        item.sharedNumber = peopleIndexes.length;
        person.result.items.push(item); // Add Item to Person's Result
        person.result.total += item.price / peopleIndexes.length; // Add Price to Person's Total
      });
    });

    const results = Object.keys(personDict).map((key) => personDict[key].result);
    setResults(results);
  }

  const stepOneParams: StepOneParams = {
    items,
    setItems,
  };

  const stepTwoParams: StepTwoParams = {
    people,
    setPeople,
    savedFriends: saveFriends,
    setSaveFriends,
  }

  const stepThreeParams: StepThreeParams = {
    items,
    people,
    splitDict,
    setSplitDict,
    setItems,
  }

  const stepFourParams: StepFourParams = {
    results
  }

  return (
    <main className="max-w-[1100px] min-w-[50vw]  w-fit h-screen m-auto py-10">
      <h1 className="text-center text-main">Let's Split the Bill</h1>

      <section className="my-20">
        <Steps
          size="small"
          current={currentStep}
          labelPlacement="vertical" 
          items={steps}
        />


        <div className="py-10">
          { getCurrentUI() }
        </div>
        
        <div className="flex flex-row justify-end gap-5">
          <div className={`flex flex-row gap-3 items-center cursor-pointer hover:opacity-50 ${ currentStep === 0 && 'cursor-not-allowed opacity-50'}`}
               onClick={ () => goBack() }>
            <p className="mb-0 w-auto text-main">Go Back</p>
            <div className="w-10 h-10 flex justify-center items-center rounded-full border border-main">
              <ArrowLeftOutlined className="text-main" />
            </div>
          </div>

          <div className={`flex flex-row gap-3 items-center cursor-pointer hover:opacity-50 ${ currentStep === (steps.length - 1) && 'cursor-not-allowed opacity-50'}`}
               onClick={ () => goNext() }>
            <div className="w-10 h-10 flex justify-center items-center rounded-full border border-main">
              <ArrowRightOutlined className="text-main" />
            </div>
            <p className="mb-0 w-auto text-main">Go Next</p>
          </div>
        </div>
      </section>
    </main>
  );
}
