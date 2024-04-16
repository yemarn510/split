'use client';

import { Input, Button, Modal, Avatar } from 'antd';
import { AVATAR_URL, Person, generateRandomInteger } from "@/models/person.models";
import { useEffect, useState } from 'react';
import { UndoOutlined, DeleteOutlined } from '@ant-design/icons';


export interface StepTwoParams {
  people: Person[];
  setPeople: Function;
}

export default function StepTwo(params: {params: StepTwoParams }): JSX.Element {

  const [isModalOpen, setIsModalOpen] = useState(false);
  const [changingAvatarIndex, setChangingAvatarIndex] = useState<number | null>(null); 
  const [avatarNumbers, setAvatarNumbers] = useState<number[]>([]);

  useEffect(() => {
    generateRandomAvatars();
  }, []);

  function addPerson(): void {
    const cloned = [...params.params.people];
    cloned.push(new Person({}));
    params.params.setPeople(cloned);
  }

  function toggleModal(index: number | null): void {
    setIsModalOpen(!isModalOpen);
    setChangingAvatarIndex(index);
  }

  function generateRandomAvatars(): void {
    const randomNumbers = [];
    for (let index = 0; index < 52; index++) {
        randomNumbers.push(generateRandomInteger(1, 1000)); // Generates random numbers between 1 and 1000
    }
    setAvatarNumbers(randomNumbers);
  }

  function changeAvatar(index: number): void {
    const cloned = [...params.params.people];
    cloned[changingAvatarIndex!].profile = `${AVATAR_URL}${avatarNumbers[index]}`;
    params.params.setPeople(cloned);
    toggleModal(null);
  }

  function deletePerson(index: number): void {
    const cloned = [...params.params.people];
    cloned.splice(index, 1);
    params.params.setPeople(cloned);
  }
  

  return <>
    <div className="flex flex-col w-full">
      <table>
        <thead>
          <tr>
            <th className='text-main pb-3 w-1/5'>No.</th>
            <th className='text-main pb-3 w-1/5'>Profile</th>
            <th className='text-main pb-3 w-2/5'>Name</th>
            <th className='w-1/5'></th>
          </tr>
        </thead>
        <tbody>
          {
            params.params.people?.map((person, index) => {
              return <tr key={`person-${index}`}>
                <td className='text-center'> { index + 1 } </td>
                <td className='text-center'>
                  <div className='bg-third cursor-pointer p-1 w-fit h-fit rounded-full m-auto hover:opacity-50'
                       onClick={() => toggleModal(index) }>
                    <Avatar src={person.profile} className='w-12 h-12 ' />
                  </div>
                </td>
                <td className='px-10'>
                  <Input type='text'
                         value={person.name}
                         placeholder='Full Name, Nickname, etc.'
                         onChange={(e) => {
                           const cloned = [...params.params.people];
                           cloned[index].name = e.target.value;
                           params.params.setPeople(cloned);
                         }}
                         className='w-full p-2 border border-main text-center rounded-md' />
                </td>
                <td className='text-center'>
                  <DeleteOutlined className="text-danger text-xl"
                                  onClick={() => deletePerson(index)}/>
                </td>
              </tr>
            })
          }
        </tbody>
      </table>

      <Button className="w-full mt-3 h-8 min-h-8"
        type="primary"
        onClick={ () => addPerson() }>
        Add Person
      </Button>

      <Modal title="Choose your Avatar"
             footer={null}
             centered
             onCancel={ () => toggleModal(null) }
             open={isModalOpen} >
        <div className='grid grid-cols-4 gap-4 h-[320px] overflow-auto p-5'>
          {
            avatarNumbers.map((eachNumber, index) => {
              return <div className='bg-third cursor-pointer p-1 w-fit h-fit rounded-full m-auto hover:opacity-50'
                          key={index}
                          onClick={() => changeAvatar(index) }>
                <Avatar src={`${AVATAR_URL}${eachNumber}`} className='w-12 h-12 ' />
              </div>
            })
          }
        </div>
        <div className='text-center mt-5'>
          <Button
            onClick={ () => generateRandomAvatars() }
            icon={<UndoOutlined />}>
            Generate Again
          </Button>
        </div>
      </Modal>
    </div>
  </>
}