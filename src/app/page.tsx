'use client';

import { Steps, message } from 'antd';
import { ArrowLeftOutlined, } from '@ant-design/icons';
import { useState, useEffect } from "react";

import StepOne, { StepOneParams } from "@/components/step-1";
import { Item } from "@/models/item.models";
import StepTwo, { StepTwoParams } from "@/components/step-2";
import { Person } from "@/models/person.models";
import StepThree, { StepThreeParams } from "@/components/step-3";
import { SplitDictionary } from "@/models/split.models";
import StepFour, { StepFourParams } from "@/components/step-4";
import { Result } from "@/models/results.models";
import LoginPopup from '@/components/login-popup';
import { calculateResults, createOrUpdateFriends, someStepsAreEmpty } from '@/functions/common.functions';
import getButton, { NextButtonProps } from '@/components/next-button';
import GetButton from '@/components/next-button';

const STEPS = ['Add People', 'Add Items', 'Assign People & Items', 'Review & Split'];

export default function Home() {

  const [currentStep, setCurrentStep] = useState(0);
  const [items, setItems] = useState<Item[]>([]);
  const [people, setPeople] = useState<Person[]>([]);
  const [splitDict, setSplitDict] = useState<SplitDictionary>({});
  const [results, setResults] = useState<Result[]>([]);
  const [saveFriends, setSaveFriends ] = useState<boolean>(false);
  const [isPremiumUser, setIsPremiumUser] = useState<boolean>(false);

  const [messageApi, contextHolder] = message.useMessage();

  const steps: { title: string}[] = STEPS.map(each => ({ title: each }));

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
    if (goNextButtonDisabled()) {
      if (currentStep === 0 && people.every(each => each.selected === false)) {
        messageApi.open({
          type: 'error',
          content: 'Please select at least one person to continue',
        });
      }
      return;
    }

    switch (currentStep) {
      case 0:
        saveFriends ?
          createOrUpdateFriends(people) :
          localStorage.removeItem('friends');
        setCurrentStep(1);
        break;
      case 1:
        if (isStepTwoValid()) {
          setCurrentStep(2);
        }
        break;
      case 2:
        if (someStepsAreEmpty(splitDict)) {
          return;
        }
        const results = calculateResults(items, people, splitDict);
        setResults(results);
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

  function isStepTwoValid(): boolean {
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

  function goNextButtonDisabled(): boolean {
      switch (currentStep) {
        case 0:
          return people.length === 0 || people.every( each => each.selected === false);
        case 1:
          return items.length === 0;
        case 2:
          return someStepsAreEmpty(splitDict);
        case 3:
          return false;
      }
    return false;
  }

  const stepOneParams: StepOneParams = {
    people,
    setPeople,
    savedFriends: saveFriends,
    setSaveFriends,
    items, 
    setItems,
  }

  const stepTwoParams: StepTwoParams = {
    items,
    setItems,
    people: people.filter(each => each.selected),
    isPremiumUser,
  };

  const stepThreeParams: StepThreeParams = {
    items,
    people: people.filter(each => each.selected),
    splitDict,
    setSplitDict,
    setItems,
  }

  const stepFourParams: StepFourParams = {
    results,
    setResults,
  }

  const getParams: NextButtonProps = {
    currentStep,
    results,
    steps,
    goNextButtonDisabled,
    goNext,
  };

  return <>
    { contextHolder }
    <main className="w-fit m-auto">
      <h1 className="text-center text-main text-4xl md:text-5xl mb-3 relative">
        Let&rsquo;s Split the Bills
      </h1>
      <div className="steps-container hidden md:flex">
        <Steps
          size="small"
          current={currentStep}
          labelPlacement="vertical" 
          items={steps}
        />
      </div>

      <div className="flex flex-row items-center justify-center gap-3 mb-2 md:hidden">
        <div className="rounded-full flex justify-center text-white items-center w-auto h-auto p-2 px-3 bg-main">
          Step:  {currentStep + 1}/{ steps.length }
        </div>
        <h4 className="text-main text-center">
          { steps[currentStep].title }
        </h4>
      </div>


      <div className="main-content">
        { getCurrentUI() }
      </div>
      
      <div className='w-full flex flex-row justify-between items-center'>
        <LoginPopup setPeople={setPeople} setIsPremiumUser={setIsPremiumUser} isPremiumUser={isPremiumUser} />

        <div className="flex flex-row mt-3 gap-3 md:gap-5 justify-end">
          <div className={`flex flex-row gap-1 md:gap-3 items-center cursor-pointer md:hover:opacity-50 ${ currentStep === 0 && 'cursor-not-allowed opacity-50'}`}
              onClick={ () => goBack() }>
            <p className="mb-0 w-auto text-main">Go Back</p>
            <div className="w-10 h-10 flex justify-center items-center rounded-full border border-main">
              <ArrowLeftOutlined className="text-main" />
            </div>
          </div>
          <GetButton params={getParams} />
        </div>
      </div>
    </main>
  </>
}